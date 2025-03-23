import pandas as pd
import streamlit as st
import plotly.express as px

# Load CSV data
@st.cache_data
def load_data():
    df = pd.read_csv('Leases.csv')
    return df

df_leases = load_data()

# 🧼 Preprocess data
df_leases['year_quarter'] = df_leases['year'].astype(str) + ' Q' + df_leases['quarter'].astype(str)

# Sort quarters chronologically
df_leases['year_quarter'] = pd.Categorical(df_leases['year_quarter'],
    sorted(df_leases['year_quarter'].unique(), key=lambda x: (int(x.split()[0]), int(x.split()[1].replace('Q', '')))), # Changed this line
    ordered=True
)

# Streamlit UI
st.title('Lease Counts per Quarter (Time Series)')

# Sidebar filters
industry_options = df_leases['internal_industry'].dropna().unique()
transaction_options = df_leases['transaction_type'].dropna().unique()

selected_industries = st.multiselect('Filter by Internal Industry', industry_options, default=list(industry_options))
selected_transactions = st.multiselect('Filter by Transaction Type', transaction_options, default=list(transaction_options))

# Apply filters
filtered_df = df_leases[
    df_leases['internal_industry'].isin(selected_industries) &
    df_leases['transaction_type'].isin(selected_transactions)
]

# Group data for plotting
grouped = (
    filtered_df
    .groupby(['year_quarter', 'state'])  # Assuming 'market' column exists
    .size()
    .reset_index(name='lease_count')
)

# Plotting
fig = px.line(
    grouped,
    x='year_quarter',
    y='lease_count',
    color='state',
    markers=True,
    title='Lease Counts by Quarter for Each Market'
)
fig.update_layout(xaxis_title='Quarter', yaxis_title='Number of Leases', xaxis_tickangle=45)

st.plotly_chart(fig, use_container_width=True)


