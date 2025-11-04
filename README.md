# Aloe Species Distribution Modelling in Arid and Semi-Arid Lands

## Problem Statement

Aloe species in Kenya's arid and semi-arid lands (ASALs) face increasing threats from climate change, habitat degradation, and overexploitation. Understanding current and future distribution patterns is critical for conservation planning, sustainable harvesting, and climate adaptation strategies. Traditional surveys are resource-intensive and spatially limited. This project addresses the need for scalable, data-driven predictions of Aloe habitat suitability across northern Kenya.

## Approach and Innovations

This project employs **ensemble species distribution modeling (SDM)** combining three powerful machine learning algorithms:
- **Random Forest (RF)**: Robust to overfitting and handles non-linear relationships
- **Gradient Boosting Machine (GBM)**: Sequential learning for improved prediction accuracy
- **Extreme Gradient Boosting (XGBoost)**: Optimized performance with regularization

**Key Innovations:**
- **Ensemble Framework**: Integrates predictions from RF, GBM, and XGBoost using weighted averaging within the Biomod2 framework, reducing model uncertainty
- **Multi-source Environmental Data**: Combines climate (CHELSA), soil (ISRIC), and topography (ASF) layers for comprehensive habitat characterization
- **Climate Scenario Projections**: Models future distributions under multiple climate scenarios to inform proactive conservation
- **Accessible Implementation**: Uses open-source R tools (Biomod2, dismo, raster) for reproducibility

## Dataset Sources

| Data Type | Source | Description |
|-----------|--------|-------------|
| **Climate** | [CHELSA](https://chelsa-climate.org/) | High-resolution bioclimatic variables (temperature, precipitation) |
| **Soil** | [ISRIC African SoilGrids](https://www.isric.org/explore/soilgrids) | Soil properties (pH, organic carbon, texture) |
| **Topography** | [Alaska Satellite Facility](https://asf.alaska.edu/) | Digital elevation models, slope, aspect |
| **Species Occurrence** | [GBIF](https://www.gbif.org/) & [iNaturalist](https://www.inaturalist.org/) | Verified Aloe species presence records |

## Results and Impact

**Model Performance:**
- **AUC (Area Under Curve)**: 0.89 (indicating excellent discriminatory ability)
- **TSS (True Skill Statistic)**: 0.76 (strong predictive performance)
- **Cross-validation Accuracy**: K-fold validation shows consistent performance across spatial subsets

**Key Findings:**
- Identified high-suitability corridors in northern Kenya's ASALs
- Climate change projections indicate potential 30-40% habitat contraction by 2050 under RCP 8.5
- Soil pH and precipitation seasonality emerged as top predictors

**Conservation Impact:**
- Provides spatial priorities for protected area designation
- Informs community-based conservation and sustainable harvesting zones
- Supports Kenya Wildlife Service and county governments in land-use planning

## Instructions for Running the Model

### Prerequisites
```r
# Install required R packages
install.packages(c("biomod2", "raster", "rgdal", "dismo", "ggplot2", "sf"))
```

### Step-by-Step Workflow

1. **Clone the Repository**
```bash
git clone https://github.com/Simonkipkurui/Aloe-species-Ensembled-Modelling.git
cd Aloe-species-Ensembled-Modelling
```

2. **Prepare Data**
   - Download environmental layers from data sources listed above
   - Place species occurrence data in `data/occurrences/` folder
   - Place environmental rasters in `data/environmental/` folder

3. **Run the Modeling Script**
```r
source("scripts/01_data_preparation.R")
source("scripts/02_biomod2_modeling.R")
source("scripts/03_ensemble_predictions.R")
source("scripts/04_visualization.R")
```

4. **Outputs**
   - Habitat suitability maps: `outputs/maps/`
   - Model evaluation metrics: `outputs/metrics/`
   - Variable importance plots: `outputs/plots/`

## Visualizations and Resources

### Key Outputs
- **Current Distribution Map**: [View Map](outputs/current_distribution.png)
- **Future Projections (2050)**: [View Projections](outputs/future_projections.png)
- **Variable Importance**: [View Chart](outputs/variable_importance.png)
- **Model Performance Comparison**: [View Analysis](outputs/model_comparison.pdf)

### Related Publications
- Project methodology and findings documented on [Medium](https://medium.com/@simonkipkuruibii)
- Interactive maps and dashboards (coming soon)

## Contact and Collaboration

Interested in collaborating on species distribution modeling or conservation GIS in Kenya?

- **GitHub**: [@Simonkipkurui](https://github.com/Simonkipkurui)
- **Email**: Available via GitHub profile
- **LinkedIn**: [Connect on LinkedIn](https://www.linkedin.com/in/simonkipkuruibii)

## Citation

If you use this methodology or code in your research, please cite:
```
Kipkurui, S. (2024). Ensemble Species Distribution Modeling of Aloe Species in Kenya's ASALs. 
GitHub Repository: https://github.com/Simonkipkurui/Aloe-species-Ensembled-Modelling
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Keywords**: GIS, Remote Sensing, Species Distribution Modeling, Machine Learning, Conservation, Biomod2, Kenya, Aloe, Climate Change, Ensemble Modeling
