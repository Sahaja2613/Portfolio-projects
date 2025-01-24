#Data Loading and Exploration:

import pandas as pd
# Load the dataset
df = pd.read_csv("path_to_hrrp_data.csv")

df.head()

# Display basic summary statistics to get an overview of the data
df.describe()

# missing values in the dataset
df.isnull().sum()

# Data Cleaning:
# Drop rows with missing values
df_clean = df.dropna()

# fill missing numerical values with the column's mean
# df.fillna(df.mean(), inplace=True)
# Remove any duplicate entries
df_clean = df_clean.drop_duplicates()

# encode categorical variables (e.g., hospital size) as numeric values
df_clean['hospital_size'] = df_clean['hospital_size'].map({'Large': 1, 'Small': 0})


# EDA:
import seaborn as sns
import matplotlib.pyplot as plt

# Distribution of readmission rates
sns.histplot(df_clean['readmission_rate'], kde=True)
plt.title('Distribution of Readmission Rates')
plt.xlabel('Readmission Rate')
plt.ylabel('Frequency')
plt.show()

# Correlation heatmap to examine relationships between numeric variables
corr_matrix = df_clean.corr()
sns.heatmap(corr_matrix, annot=True, cmap='coolwarm', fmt='.2f')
plt.title('Correlation Heatmap')
plt.show()

# Trends in Readmission Rates Over Time by Region
# Extract year from the discharge date (if present) and group by region and year
df_clean['year'] = pd.to_datetime(df_clean['discharge_date']).dt.year
regional_trends = df_clean.groupby(['region', 'year'])['readmission_rate'].mean().reset_index()

# Plot trends in readmission rates by region
plt.figure(figsize=(10, 6))
sns.lineplot(x='year', y='readmission_rate', hue='region', data=regional_trends)
plt.title('Trends in Readmission Rates by Region Over Time')
plt.xlabel('Year')
plt.ylabel('Average Readmission Rate')
plt.legend(title='Region')
plt.show()

# Correlation Between Hospital Characteristics and Readmission Rates
# Visualizing readmission rate by hospital size
plt.figure(figsize=(8, 6))
sns.boxplot(x='hospital_size', y='readmission_rate', data=df_clean)
plt.title('Readmission Rate by Hospital Size')
plt.xlabel('Hospital Size')
plt.ylabel('Readmission Rate')
plt.show()

# Correlation between hospital characteristics and readmission rates
hospital_corr = df_clean[['hospital_size', 'age', 'readmission_rate']].copy()
sns.pairplot(hospital_corr)
plt.show()

# Impact of Medical Conditions on Readmission Rates
# Boxplot of readmission rates by medical condition
plt.figure(figsize=(10, 6))
sns.boxplot(x='condition_type', y='readmission_rate', data=df_clean)
plt.title('Readmission Rate by Medical Condition')
plt.xlabel('Condition Type')
plt.ylabel('Readmission Rate')
plt.xticks(rotation=90)
plt.show()

# Financial Impact of HRRP Penalties
# Create a new column that flags hospitals with high readmission rates (threshold = 0.2)
df_clean['penalty'] = df_clean['readmission_rate'].apply(lambda x: 1 if x > 0.2 else 0)

# Sum of penalties by hospital size
penalty_impact = df_clean.groupby('hospital_size')['penalty'].sum().reset_index()
print(penalty_impact)


# Machine Learning for Predictive Modeling
# Define features (X) and target (y)
X = df.drop('readmission', axis=1)  # All columns except 'readmission'
y = df['readmission']  # Target column

# Split the data into training and testing sets (80% train, 20% test)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
# Initialize and train a Logistic Regression model
log_reg_model = LogisticRegression(max_iter=1000)
log_reg_model.fit(X_train, y_train)

# Predict on the test set
y_pred_log_reg = log_reg_model.predict(X_test)

# Evaluate the model
print(f'Logistic Regression Accuracy: {accuracy_score(y_test, y_pred_log_reg)}')
print(f'Classification Report:\n{classification_report(y_test, y_pred_log_reg)}')
print(f'Confusion Matrix:\n{confusion_matrix(y_test, y_pred_log_reg)}')

# Initialize and train a Random Forest model
rf_model = RandomForestClassifier(random_state=42)
rf_model.fit(X_train, y_train)
# Predict on the test set
y_pred_rf = rf_model.predict(X_test)

# Evaluate the model
print(f'Random Forest Accuracy: {accuracy_score(y_test, y_pred_rf)}')
print(f'Classification Report:\n{classification_report(y_test, y_pred_rf)}')
print(f'Confusion Matrix:\n{confusion_matrix(y_test, y_pred_rf)}')

# Get feature importances from Random Forest model
feature_importances = rf_model.feature_importances_

# Create a DataFrame to display feature importance
feature_importance_df = pd.DataFrame({
    'Feature': X.columns,
    'Importance': feature_importances
}).sort_values(by='Importance', ascending=False)

# Plot feature importances
plt.figure(figsize=(10, 6))
sns.barplot(x='Importance', y='Feature', data=feature_importance_df)
plt.title('Feature Importance from Random Forest')
plt.show()
