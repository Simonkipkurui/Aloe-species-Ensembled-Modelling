# Aloe Species Distribution Modelling in Baringo

## Description
This project focuses on modeling the distribution of Aloe species in the Baringo region using geospatial and environmental data. The goal is to predict the potential habitats of Aloe species based on various environmental factors such as climate, soil, and topography.


The following data sources were used in this project:

Climate Data: CHELSA

Soil Data: SoilGrids

Topography Data: SRTM

Species Occurrence Data: GBIF
Methodology
The distribution modeling was performed using the following steps:

Data Collection: Gather species occurrence data and environmental layers.

Data Preprocessing: Clean and prepare the data for analysis.

Modeling: Use a species distribution model Random forest ,Gradient boost machine , Extreme gradient boosting and Ensembled modelling  to predict habitat suitability.

Validation: Validate the model using  K- fold cross-validation and independent test data.

Visualization: Generate maps and visualizations of the predicted distributions.
Contributing
Contributions are welcome! If you'd like to contribute, please follow these steps:

Fork the repository.

Create a new branch for your feature or bug fix:

bash
Copy
git checkout -b feature-name
Commit your changes:

bash
Copy
git commit -m "Add your message here"
Push to the branch:

bash
Copy
git push origin feature-name
Open a pull request.
Acknowledgments
Special thanks to CHELSA and GBIF for providing the data used in this project.

This project was inspired by the need to conserve Aloe species in the Baringo region.
