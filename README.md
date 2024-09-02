# TargexFinal Trading Robot: User Guide and Explanation
#Bot developped by Volgat (MA)
## English Version

### Introduction

TargexFinal is an advanced Expert Advisor (EA) for MetaTrader 5, designed to make autonomous trading decisions using reinforcement learning techniques, specifically Q-learning. This guide will help you understand how to use the EA and explain its underlying algorithms and capabilities.

### Installation

1. Copy the TargexFinal.mq5 file to your MetaTrader 5 Experts folder.
2. Restart MetaTrader 5 or refresh the Navigator window.
3. Drag and drop the TargexFinal EA onto a chart.

### Configuration

The EA uses several input parameters that can be adjusted:

- LearningRate: Controls how quickly the model adapts to new information (default: 0.1)
- DiscountFactor: Balances immediate vs. future rewards (default: 0.95)
- InitialEpsilonInput: Starting exploration rate (default: 1.0)
- MinimumEpsilon: Minimum exploration rate (default: 0.1)
- EpsilonDecayRate: Rate at which exploration decreases (default: 0.01)
- RiskPerTrade: Percentage of account balance risked per trade (default: 0.02)
- MaxPosition: Maximum number of open positions (default: 5)
- ExplorationPeriod: Number of ticks between forced exploration actions (default: 1000)
- TargetDrawdown: Maximum allowed drawdown before model reset (default: 0.1)
- ValidationPeriod: Number of ticks between model validations (default: 500)
- ATRPeriod: Period for ATR calculation (default: 14)

### Usage

Once configured and attached to a chart, the EA will:

1. Analyze market conditions on each tick
2. Choose trading actions based on its learned strategy
3. Execute trades when conditions are favorable
4. Continuously learn and adapt its strategy

The EA will automatically manage positions, including setting dynamic stop-losses and take-profits.

### Capabilities and Algorithms

TargexFinal employs several sophisticated algorithms and techniques:

1. Q-learning: A reinforcement learning algorithm that learns an optimal action-selection policy by updating a Q-table of state-action values.

2. Epsilon-greedy Exploration: Balances exploration of new strategies with exploitation of known profitable actions.

3. Dynamic State Determination: Uses price movements and volatility (ATR) to determine the current market state.

4. Risk Management: Implements position sizing based on account balance and user-defined risk parameters. Uses ATR for dynamic stop-loss calculation.

5. Performance Metrics: Tracks various performance indicators including Sharpe ratio, maximum drawdown, win/loss ratio, and profit factor.

6. Model Validation and Persistence: Periodically evaluates the model's performance, saving the best-performing version and reverting to it if performance degrades.

7. Adaptive Learning: The learning rate and exploration rate (epsilon) are adjusted over time to optimize the learning process.

### Monitoring and Maintenance

- Regularly check the EA's performance using the built-in metrics.
- The Q-table is automatically saved and can be loaded for continued learning across multiple sessions.
- If drawdown exceeds the target, the model will automatically reset.

### Conclusion

TargexFinal is a sophisticated trading robot that combines reinforcement learning with traditional trading techniques. It's designed to adapt to changing market conditions while managing risk. Regular monitoring and parameter tuning may be necessary for optimal performance.

## Version Française
#Bot creer par Volgat(MA)
### Introduction

TargexFinal est un Expert Advisor (EA) avancé pour MetaTrader 5, conçu pour prendre des décisions de trading autonomes en utilisant des techniques d'apprentissage par renforcement, spécifiquement le Q-learning. Ce guide vous aidera à comprendre comment utiliser l'EA et expliquera ses algorithmes et capacités sous-jacents.

### Installation

1. Copiez le fichier TargexFinal.mq5 dans votre dossier Experts de MetaTrader 5.
2. Redémarrez MetaTrader 5 ou actualisez la fenêtre Navigator.
3. Faites glisser et déposez l'EA TargexFinal sur un graphique.

### Configuration

L'EA utilise plusieurs paramètres d'entrée qui peuvent être ajustés :

- LearningRate : Contrôle la vitesse d'adaptation du modèle aux nouvelles informations (par défaut : 0.1)
- DiscountFactor : Équilibre les récompenses immédiates vs futures (par défaut : 0.95)
- InitialEpsilonInput : Taux d'exploration initial (par défaut : 1.0)
- MinimumEpsilon : Taux d'exploration minimum (par défaut : 0.1)
- EpsilonDecayRate : Taux de diminution de l'exploration (par défaut : 0.01)
- RiskPerTrade : Pourcentage du solde du compte risqué par trade (par défaut : 0.02)
- MaxPosition : Nombre maximum de positions ouvertes (par défaut : 5)
- ExplorationPeriod : Nombre de ticks entre les actions d'exploration forcées (par défaut : 1000)
- TargetDrawdown : Drawdown maximum autorisé avant réinitialisation du modèle (par défaut : 0.1)
- ValidationPeriod : Nombre de ticks entre les validations du modèle (par défaut : 500)
- ATRPeriod : Période pour le calcul de l'ATR (par défaut : 14)

### Utilisation

Une fois configuré et attaché à un graphique, l'EA va :

1. Analyser les conditions du marché à chaque tick
2. Choisir des actions de trading basées sur sa stratégie apprise
3. Exécuter des trades lorsque les conditions sont favorables
4. Apprendre et adapter continuellement sa stratégie

L'EA gèrera automatiquement les positions, y compris la définition de stop-loss et take-profit dynamiques.

### Capacités et Algorithmes

TargexFinal emploie plusieurs algorithmes et techniques sophistiqués :

1. Q-learning : Un algorithme d'apprentissage par renforcement qui apprend une politique optimale de sélection d'actions en mettant à jour une table Q de valeurs état-action.

2. Exploration Epsilon-greedy : Équilibre l'exploration de nouvelles stratégies avec l'exploitation d'actions connues comme rentables.

3. Détermination Dynamique de l'État : Utilise les mouvements de prix et la volatilité (ATR) pour déterminer l'état actuel du marché.

4. Gestion du Risque : Implémente un dimensionnement des positions basé sur le solde du compte et les paramètres de risque définis par l'utilisateur. Utilise l'ATR pour le calcul dynamique du stop-loss.

5. Métriques de Performance : Suit divers indicateurs de performance, y compris le ratio de Sharpe, le drawdown maximum, le ratio gain/perte et le facteur de profit.

6. Validation et Persistance du Modèle : Évalue périodiquement la performance du modèle, sauvegardant la version la plus performante et y revenant si la performance se dégrade.

7. Apprentissage Adaptatif : Le taux d'apprentissage et le taux d'exploration (epsilon) sont ajustés au fil du temps pour optimiser le processus d'apprentissage.

### Suivi et Maintenance

- Vérifiez régulièrement les performances de l'EA en utilisant les métriques intégrées.
- La table Q est automatiquement sauvegardée et peut être chargée pour un apprentissage continu sur plusieurs sessions.
- Si le drawdown dépasse la cible, le modèle se réinitialisera automatiquement.

### Conclusion

TargexFinal est un robot de trading sophistiqué qui combine l'apprentissage par renforcement avec des techniques de trading traditionnelles. Il est conçu pour s'adapter aux conditions changeantes du marché tout en gérant les risques. Un suivi régulier et un ajustement des paramètres peuvent être nécessaires pour une performance optimale.
