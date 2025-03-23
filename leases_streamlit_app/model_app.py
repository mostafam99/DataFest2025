# === STREAMLIT APP (app.py) ===
import streamlit as st
import pandas as pd
import numpy as np
import joblib
import json

# Load model and metadata
model = joblib.load("linear_regression_model.pkl")
model_columns = joblib.load("model_columns.pkl")
label_columns = joblib.load("label_columns.pkl")

with open("feature_config.json") as f:
    config = json.load(f)

feature_mappings = config["feature_mappings"]
bins = config["bins"]
labels = config["labels"]
binned_features = ["leasedSF", "overall_rent"]

# UI for user input
st.title("City Predictor")

user_input = {
    "market": st.selectbox("Market", feature_mappings["market"]),
    "internal_submarket": st.selectbox("Internal Submarket", feature_mappings["internal_submarket"]),
    "leasedSF": st.slider("Leased SF", 0, 50000, 5000),
    "internal_industry": st.selectbox("Internal Industry", feature_mappings["internal_industry"]),
    "overall_rent": st.slider("Overall Rent", 0, 100, 25),
    "transaction_type": st.selectbox("Transaction Type", feature_mappings["transaction_type"])
}

# Manual encoding function
def manual_encode(user_input):
    encoded = []
    for i, feat in enumerate(binned_features):
        val = user_input[feat]
        binned_val = pd.cut([val], bins=bins[i], labels=labels[i], include_lowest=True)[0]
        encoded.extend([int(binned_val == l) for l in labels[i]])
    for feat in feature_mappings:
        val = user_input[feat]
        encoded.extend([int(val == cat) for cat in feature_mappings[feat]])
    return np.array(encoded).reshape(1, -1)

# Predict button
if st.button("Predict City"):
    encoded_input = manual_encode(user_input)
    st.write("Encoded Input:")
    st.write(encoded_input)

    prediction = model.predict(encoded_input)
    predicted_index = np.argmax(prediction, axis=1)[0]
    predicted_city = label_columns[predicted_index]

    st.success(f"Predicted City: **{predicted_city}**")