# Loading the libraries
library(tidyverse)
library(readr)
library(ggplot2)
library(dplyr)

# Load the dataset
cdi_data <- read_csv("CDI_2023.csv")

# Inspect the first few rows of the data
head(cdi_data)

# Exploratory Data Analysis (EDA)
# Prevalence by State
# Calculate average chronic disease prevalence by state
state_prevalence <- cdi_data %>%
  group_by(State) %>%
  summarise(avg_prevalence = mean(ChronicDiseasePrevalence, na.rm = TRUE))

# Plot the state-level prevalence
ggplot(state_prevalence, aes(x = reorder(State, avg_prevalence), y = avg_prevalence)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Chronic Disease Prevalence by State",
       x = "State", y = "Average Prevalence (%)")

# Chronic Disease Prevalence by Risk Factors (Obesity, Smoking, Physical Inactivity)
# Scatter plot of chronic disease prevalence vs. obesity rate
ggplot(cdi_data, aes(x = ObesityRate, y = ChronicDiseasePrevalence)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(title = "Chronic Disease Prevalence vs Obesity Rate",
       x = "Obesity Rate (%)", y = "Chronic Disease Prevalence (%)")

# Scatter plot of chronic disease prevalence vs. smoking rate
ggplot(cdi_data, aes(x = SmokingRate, y = ChronicDiseasePrevalence)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(title = "Chronic Disease Prevalence vs Smoking Rate",
       x = "Smoking Rate (%)", y = "Chronic Disease Prevalence (%)")

# Chronic Disease Prevalence by Demographics (Age, Gender, Ethnicity)
# Boxplot of chronic disease prevalence by gender
ggplot(cdi_data, aes(x = Gender, y = ChronicDiseasePrevalence)) +
  geom_boxplot() +
  labs(title = "Chronic Disease Prevalence by Gender",
       x = "Gender", y = "Chronic Disease Prevalence (%)")

# Boxplot of chronic disease prevalence by age group
ggplot(cdi_data, aes(x = AgeGroup, y = ChronicDiseasePrevalence)) +
  geom_boxplot() +
  labs(title = "Chronic Disease Prevalence by Age Group",
       x = "Age Group", y = "Chronic Disease Prevalence (%)")

# Boxplot of chronic disease prevalence by ethnicity
ggplot(cdi_data, aes(x = Ethnicity, y = ChronicDiseasePrevalence)) +
  geom_boxplot() +
  labs(title = "Chronic Disease Prevalence by Ethnicity",
       x = "Ethnicity", y = "Chronic Disease Prevalence (%)")
