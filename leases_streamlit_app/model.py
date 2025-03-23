# === TRAINING SCRIPT (train_model.py) ===
import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
import joblib
import json

# Define features
features = [
    "market",
    "internal_submarket",
    "leasedSF",
    "internal_industry",
    "overall_rent",
    "transaction_type"
]

outputFeatures = ["city"]

# Binned numerical features
binnedFeatures = ["leasedSF", "overall_rent"]
bins = [
    [0, 2000, 4000, 6000, 8000, 10000, 20000, 50000],
    [0, 10, 20, 30, 40, 50, 60, 100]
]
labels = [
    ["0-2k", "2-4k", "4-6k", "6-8k", "8-10k", "10-20k", "20-50k"],
    ["0-10", "10-20", "20-30", "30-40", "40-50", "50-60", "60-100"]
]

# Load and clean data
df = pd.read_csv("./Leases.csv").dropna()

# Extract category mappings
feature_mappings = {}
for feature in ["market", "internal_submarket", "internal_industry", "transaction_type"]:
    feature_mappings[feature] = sorted(df[feature].unique().tolist())

# Save mappings and bins
with open("feature_config.json", "w") as f:
    json.dump({
        "feature_mappings": feature_mappings,
        "bins": bins,
        "labels": labels
    }, f)

# Manual encoding function
def manual_encode(df_row):
    encoded = []
    for i, feat in enumerate(binnedFeatures):
        val = df_row[feat]
        binned_val = pd.cut([val], bins=bins[i], labels=labels[i], include_lowest=True)[0]
        encoded.extend([int(binned_val == l) for l in labels[i]])
    for feat in feature_mappings:
        val = df_row[feat]
        encoded.extend([int(val == cat) for cat in feature_mappings[feat]])
    return encoded

# Apply encoding to full dataset
encoded_data = df.apply(manual_encode, axis=1, result_type='expand')
X = pd.DataFrame(encoded_data)
Y = pd.get_dummies(df[outputFeatures[0]], drop_first=True)

# Train/test split
X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size=0.2, random_state=42)

# Train model
model = LinearRegression()
model.fit(X_train, Y_train)

# Save model and training column count
joblib.dump(model, "linear_regression_model.pkl")
joblib.dump(X.columns.tolist(), "model_columns.pkl")
joblib.dump(Y.columns.tolist(), "label_columns.pkl")