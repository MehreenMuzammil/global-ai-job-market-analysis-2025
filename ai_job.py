#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Load dataset
df = pd.read_csv("ai_job_dataset.csv")

# Quick overview
print(df.shape)
print(df.info())
df.head()


# In[2]:


#Data Cleaning


# In[3]:


# Convert date columns
df['posting_date'] = pd.to_datetime(df['posting_date'])
df['application_deadline'] = pd.to_datetime(df['application_deadline'])

#Missing values
df.isnull().sum()

#Remove duplicates
df = df.drop_duplicates()
print("Cleaned dataset : ", df.shape)


# In[4]:


#Exploratory Data Analysis (EDA)


# In[5]:


#Salary distribution
plt.figure(figsize=(10,6))
top_countries = df['company_location'].value_counts().head(6).index
sns.boxplot(x='company_location', y='salary_usd', data=df[df['company_location'].isin(top_countries)])
plt.title('Salary Comparison by Country')
plt.xlabel('Country')
plt.ylabel('Salary (USD)')
plt.show()


# In[6]:


#Top 15 company locations
plt.figure(figsize = (8,5))
df['company_location'].value_counts().head(15).plot(kind='bar', color = 'teal')

plt.title('Top 15 company locations')
plt.xlabel('Country')
plt.ylabel('Job count')
plt.show()


# In[7]:


#Experience vs Salary
plt.figure( figsize = (8,5))
sns.boxplot( x = 'experience_level', y = 'salary_usd', data = df, color = 'red')

plt.xlabel('Experience level')
plt.ylabel('Salary')
plt.title('Salary by Experience Level')
plt.show()


# In[8]:


#Monthly job postings trend
if 'posting_date' in df.columns:
    monthly_trend = df.set_index ('posting_date').resample('M').size()
    plt.figure(figsize = (6,4))
    monthly_trend.plot(marker = 'o')
    plt.title('Monthly AI Job Postings Trend')
    plt.xlabel('Month')
    plt.ylabel('Number of Jobs')
    plt.grid(True)
    plt.show()


# In[9]:


#Skills Analysis


# In[10]:


# Split skills into lists
df['required_skills_list'] = df['required_skills'].apply(lambda x: [s.strip() for s in x.split(',')])

# Flatten and count the most frequent skills
from collections import Counter
skill_counts = Counter([skill for skills in df['required_skills_list'] for skill in skills])
top_skills = pd.DataFrame(skill_counts.most_common(10), columns=['Skill', 'Count'])

# Visualization
plt.figure(figsize=(8,5))
sns.barplot(x='Count', y='Skill', data=top_skills, palette='coolwarm')
plt.title('Top 10 Most In-Demand AI Skills')
plt.show()


# In[11]:


#Correlation Analysis


# In[12]:


plt.figure(figsize=(8,6))
sns.heatmap(df.corr(numeric_only=True), annot=True, cmap='crest')
plt.title('Correlation Between Numerical Features')
plt.show()


# In[ ]:





# In[13]:


#Job Roles vs Salary (Top 10 Roles)
top_roles = df['job_title'].value_counts().head(10).index
plt.figure(figsize=(10,6))
sns.barplot(y='job_title', x='salary_usd', data=df[df['job_title'].isin(top_roles)], estimator=np.mean)
plt.title('Average Salary by Top 10 Job Roles')
plt.xlabel('Average Salary (USD)')
plt.ylabel('Job Title')
plt.show()


# In[14]:


#Summary Metrics 
print("Average salary by country:")
print(df.groupby('company_location')['salary_usd'].mean().sort_values(ascending=False).head(10))

print("\nMost common job titles:")
print(df['job_title'].value_counts().head(10))

print("\nTop experience levels:")
print(df['experience_level'].value_counts())


# In[15]:


#Save Cleaned Data
df.to_csv("cleaned_ai_job_dataset.csv", index=False)

