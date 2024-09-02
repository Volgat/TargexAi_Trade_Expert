//+------------------------------------------------------------------+
//|                                        TargexFinal.mq5           |
//|                                   Copyright 2024, .            |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Volgat (Mike Amega)"
#property version   "2.05"
#property description "TargexFinal - Expert Advisor without indicators (MQL5 Version)"

#include <Trade\Trade.mqh>

// Input parameters
input double LearningRate = 0.1;
input double DiscountFactor = 0.95;
input double InitialEpsilonInput = 1.0;
input double MinimumEpsilon = 0.1;
input double EpsilonDecayRate = 0.01;
input double RiskPerTrade = 0.02;
input int MaxPosition = 5;
input int ExplorationPeriod = 1000;
input double TargetDrawdown = 0.1;
input int ValidationPeriod = 500;
input int ATRPeriod = 14;

// Global variables
double QTable[3][2][2];
int CurrentState;
int CurrentAction;
double CurrentReward;
int OpenPositionType = -1;
double InitialBalance;
double InitialEpsilon;
double MaxDrawdown;
int TickCount = 0;
double ValidationPerformance = 0;
double BestPerformance = 0;
double BestQTable[3][2][2];

// Performance metrics structure
struct PerformanceMetrics {
    double sharpeRatio;
    double maxDrawdown;
    double winLossRatio;
    double profitFactor;
};

PerformanceMetrics metrics;

CTrade trade; // Global trade object

// Q-learning class
class QLearning {
private:
    double learningRate;
    double discountFactor;
    double epsilon;

public:
    QLearning(double lr, double df, double eps) : learningRate(lr), discountFactor(df), epsilon(eps) {}

    void UpdateQTable(int previousState, int previousAction, double reward, int newState) {
        double maxQValue = -1.0;
        int maxQAction = -1;

        for (int i = 0; i < 2; i++) {
            if (QTable[newState][i][0] > maxQValue) {
                maxQValue = QTable[newState][i][0];
                maxQAction = i;
            }
        }

        double newQValue = reward + discountFactor * QTable[newState][maxQAction][0];
        QTable[previousState][previousAction][0] += learningRate * (newQValue - QTable[previousState][previousAction][0]);
    }

    int ChooseAction() {
        if (TickCount % ExplorationPeriod == 0) {
            return MathRand() % 2;
        }

        if (MathRand() / 32767.0 < epsilon) {
            return MathRand() % 2;
        } else {
            return QTable[CurrentState][0][0] > QTable[CurrentState][1][0] ? 0 : 1;
        }
    }

    void AdaptEpsilon() {
        epsilon = MathMax(epsilon - EpsilonDecayRate, MinimumEpsilon);
    }
};

QLearning qLearning(LearningRate, DiscountFactor, InitialEpsilonInput);

// Trading operations class
class TradingOperations {
public:
    void Buy(string symbol, double lotSize) {
        if (PositionsTotal() < MaxPosition && OpenPositionType != 1) {
            double price = SymbolInfoDouble(symbol, SYMBOL_ASK);
            double stopLoss = CalculateDynamicStopLoss(symbol, price, true);
            double takeProfit = CalculateTakeProfit(price, true);
            if (trade.Buy(lotSize, symbol, price, stopLoss, takeProfit, "TargexFinal")) {
                Print("Buy order placed successfully");
                OpenPositionType = 0;
            } else {
                LogError("OrderSend failed", GetLastError());
            }
        }
    }

    void Sell(string symbol, double lotSize) {
        if (PositionsTotal() < MaxPosition && OpenPositionType != 0) {
            double price = SymbolInfoDouble(symbol, SYMBOL_BID);
            double stopLoss = CalculateDynamicStopLoss(symbol, price, false);
            double takeProfit = CalculateTakeProfit(price, false);
            if (trade.Sell(lotSize, symbol, price, stopLoss, takeProfit, "TargexFinal")) {
                Print("Sell order placed successfully");
                OpenPositionType = 1;
            } else {
                LogError("OrderSend failed", GetLastError());
            }
        }
    }

    void CloseAllPositions() {
        for (int i = PositionsTotal() - 1; i >= 0; i--) {
            ulong ticket = PositionGetTicket(i);
            if (PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == Symbol()) {
                trade.PositionClose(ticket);
            }
        }
    }
};

TradingOperations tradeOps;

// Function to calculate ATR manually
double CalculateATR(int period) {
    double sum = 0;
    for (int i = 1; i <= period; i++) {
        double high = iHigh(Symbol(), PERIOD_CURRENT, i);
        double low = iLow(Symbol(), PERIOD_CURRENT, i);
        double closePrevi = iClose(Symbol(), PERIOD_CURRENT, i + 1);
        
        double tr = MathMax(high - low, MathMax(MathAbs(high - closePrevi), MathAbs(low - closePrevi)));
        sum += tr;
    }
    return sum / period;
}

// Function to calculate Simple Moving Average manually
double CalculateSMA(int period) {
    double sum = 0;
    for (int i = 0; i < period; i++) {
        sum += iClose(Symbol(), PERIOD_CURRENT, i);
    }
    return sum / period;
}

// Function to determine the state based on historical data and volatility
int DetermineState(string symbol, int shift) {
    double previousPrice = iClose(symbol, PERIOD_CURRENT, shift + 1);
    double currentPrice = iClose(symbol, PERIOD_CURRENT, shift);
    
    double atr = CalculateATR(ATRPeriod);
    double averageATR = CalculateSMA(ATRPeriod);

    int priceState = (currentPrice > previousPrice) ? 0 : 1;
    int volatilityState = (atr > averageATR) ? 1 : 0;

    return priceState + volatilityState * 2;
}

// Function to determine the reward based on the action taken
double DetermineReward(int action, string symbol, int shift) {
    double previousPrice = iClose(symbol, PERIOD_CURRENT, shift + 1);
    double currentPrice = iClose(symbol, PERIOD_CURRENT, shift);
    double priceDifference = MathAbs(currentPrice - previousPrice);
    
    double riskAdjustedReturn = priceDifference / (SymbolInfoDouble(symbol, SYMBOL_POINT) * 10);
    
    if ((action == 0 && currentPrice > previousPrice) || (action == 1 && currentPrice < previousPrice)) {
        return riskAdjustedReturn;
    } else {
        return -riskAdjustedReturn;
    }
}

// Function to calculate lot size based on risk per trade
double CalculateLotSize() {
    double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double riskAmount = accountBalance * RiskPerTrade;
    double tickValue = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE);
    
    double atr = CalculateATR(ATRPeriod);
    double stopLossPips = atr / SymbolInfoDouble(Symbol(), SYMBOL_POINT);

    double lotSize = NormalizeDouble(riskAmount / (stopLossPips * tickValue), 2);
    double minLot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);

    return MathMax(MathMin(lotSize, maxLot), minLot);
}

// Function to calculate dynamic stop-loss
double CalculateDynamicStopLoss(string symbol, double entryPrice, bool isBuy) {
    double atr = CalculateATR(ATRPeriod);
    return isBuy ? entryPrice - 2 * atr : entryPrice + 2 * atr;
}

// Function to calculate take-profit
double CalculateTakeProfit(double entryPrice, bool isBuy) {
    double atr = CalculateATR(ATRPeriod);
    return isBuy ? entryPrice + 3 * atr : entryPrice - 3 * atr;
}

// Function to check if there are any open positions
bool IsAnyOpenPosition() {
    return PositionsTotal() >= MaxPosition;
}

// Function to update performance metrics
void UpdatePerformanceMetrics() {
    static double totalProfit = 0;
    static double totalLoss = 0;
    static int winCount = 0;
    static int lossCount = 0;

    double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);

    double currentDrawdown = (InitialBalance - currentEquity) / InitialBalance;
    MaxDrawdown = MathMax(MaxDrawdown, currentDrawdown);

    HistorySelect(0, TimeCurrent());
    for (int i = HistoryDealsTotal() - 1; i >= 0; i--) {
        ulong ticket = HistoryDealGetTicket(i);
        if (HistoryDealGetString(ticket, DEAL_SYMBOL) == Symbol()) {
            double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
            if (profit > 0) {
                totalProfit += profit;
                winCount++;
            } else {
                totalLoss += MathAbs(profit);
                lossCount++;
            }
        }
    }

    metrics.winLossRatio = (lossCount > 0) ? (double)winCount / lossCount : winCount;
    metrics.profitFactor = (totalLoss > 0) ? totalProfit / totalLoss : totalProfit;
    
    double returns = (currentBalance - InitialBalance) / InitialBalance;
    double riskFreeRate = 0.02;
    metrics.sharpeRatio = (returns - riskFreeRate) / MathSqrt(MaxDrawdown);
    metrics.maxDrawdown = MaxDrawdown;
}

// Function to log errors
void LogError(string message, int errorCode) {
    Print("Error: ", message, " (Code: ", errorCode, ")");
    // Add code here to log the error to a file
}

// Function to save the Q-table to a file
void SaveQTable() {
    int handle = FileOpen("QTable.bin", FILE_WRITE|FILE_BIN);
    if (handle != INVALID_HANDLE) {
        FileWriteArray(handle, QTable, 0, ArraySize(QTable));
        FileClose(handle);
    } else {
        LogError("Error opening file for writing", GetLastError());
    }
}

// Function to load the Q-table from a file
void LoadQTable() {
    int handle = FileOpen("QTable.bin", FILE_READ|FILE_BIN);
    if (handle != INVALID_HANDLE) {
        FileReadArray(handle, QTable, 0, ArraySize(QTable));
        FileClose(handle);
    } else {
        LogError("Error opening file for reading", GetLastError());
    }
}

// Function to reset the model
void ResetModel() {
    ArrayInitialize(QTable, 0);
    InitialEpsilon = InitialEpsilonInput;
    Print("Model reset due to excessive drawdown");
}

// Function to validate the model
void ValidateModel() {
    double currentPerformance = CalculatePerformance();

    if (currentPerformance > BestPerformance) {
        BestPerformance = currentPerformance;
        ArrayCopy(BestQTable, QTable);
        Print("New best model saved. Performance: ", BestPerformance);
    } else if (currentPerformance < ValidationPerformance) {
        ArrayCopy(QTable, BestQTable);
        Print("Reverted to previous best model. Current performance: ", currentPerformance);
    }

    ValidationPerformance = currentPerformance;
}

// Function to calculate performance
double CalculatePerformance() {
    return metrics.sharpeRatio * (1 - metrics.maxDrawdown);
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
    LoadQTable();
    InitialBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    InitialEpsilon = InitialEpsilonInput;
    MaxDrawdown = 0;
    TickCount = 0;
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    tradeOps.CloseAllPositions();
    SaveQTable();
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
    TickCount++;

    int state = DetermineState(Symbol(), 0);
    int action = qLearning.ChooseAction();

    double lotSize = CalculateLotSize();

    if (!IsAnyOpenPosition()) {
        if (action == 0) {
            tradeOps.Buy(Symbol(), lotSize);
        } else if (action == 1) {
            tradeOps.Sell(Symbol(), lotSize);
        }
    }

    double reward = DetermineReward(action, Symbol(), 0);
    qLearning.UpdateQTable(CurrentState, CurrentAction, reward, state);

    CurrentState = state;
    CurrentAction = action;

    UpdatePerformanceMetrics();
    qLearning.AdaptEpsilon();

    if (metrics.maxDrawdown > TargetDrawdown) {
        ResetModel();
    }

    if (TickCount % ValidationPeriod == 0) {
        ValidateModel();
    }

    if (TickCount % 10000 == 0) {
        SaveQTable();
    }
}