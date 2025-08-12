# Real-World Testing Infrastructure for zoomstudentengagement

**Infrastructure files for creating standalone real-world testing environments.**

This directory contains the testing infrastructure that can be copied to create standalone testing projects for validating the `zoomstudentengagement` package with real confidential data.

## 🚀 Quick Setup

### 1. Create Standalone Testing Project
```bash
# From the project root, copy the entire infrastructure
cp -r scripts/real_world_testing/ my_testing_project/

# Navigate to your testing project
cd my_testing_project

# Run the setup script
./setup.sh
```

### 2. Alternative: Test from Package Root
```bash
# If you want to test the development version from the package root
cd /path/to/zoomstudentengagement
./scripts/real_world_testing/run_tests.sh
```

### 2. Add Your Data
```bash
# Add your Zoom transcript files
cp /path/to/your/transcripts/*.vtt data/transcripts/

# Add your roster and session metadata
cp /path/to/your/roster.csv data/metadata/
cp /path/to/your/zoomus_recordings__*.csv data/metadata/
```

### 3. Validate and Run Tests
```bash
# Validate your data (optional)
./validate_data.sh

# Run all tests
./run_tests.sh

# Or work through the manual workflow
./run_manual_workflow.sh
```

## ⚠️ **SECURITY WARNING**

**CRITICAL**: This testing involves real student data and must be conducted in a secure environment.

- **❌ NEVER** run in Cursor, GitHub Codespaces, or other LLM/IDE environments
- **❌ NEVER** commit or share test results containing sensitive information
- **✅ ALWAYS** use a secure terminal or isolated environment
- **✅ ALWAYS** ensure data privacy and confidentiality

## 📁 Infrastructure Files

```
scripts/real_world_testing/           # Infrastructure files (this directory)
├── README.md                         # This file
├── setup.sh                          # Environment setup and validation
├── validate_data.sh                  # Data validation script wrapper
├── validate_data.R                   # R data validation functions
├── run_tests.sh                      # Test runner script
├── run_real_world_tests.R            # Main testing script
├── whole_game_real_world.Rmd         # Manual workflow document
├── run_manual_workflow.sh            # Manual workflow runner
├── real_world_test_plan.md           # Comprehensive testing plan
└── config_example.R                  # Example configuration file

# When copied to standalone project:
my_testing_project/                   # Standalone project root
├── data/                             # Your test data goes here
│   ├── transcripts/                  # Zoom transcript files (.vtt, .txt, .csv)
│   └── metadata/                     # Roster and session data
├── reports/                          # Generated test reports
├── outputs/                          # Generated plots and files
├── .gitignore                        # Protects sensitive data
└── [all infrastructure files above]
```

## 🔧 Setup Process

### Testing Environments

This infrastructure supports two testing approaches:

1. **Development Testing** (from package root): Tests the latest development version
   - Run from `/path/to/zoomstudentengagement`
   - Uses `devtools::load_all()` to load development code
   - Best for testing new features and fixes

2. **Production Testing** (standalone environment): Tests the installed package version
   - Run from external directory (e.g., `/Users/piper/git/zse_secure_testing`)
   - Uses `library(zoomstudentengagement)` to load installed package
   - Best for validating production behavior with real data

### Manual Workflow vs Automated Testing

This infrastructure provides two approaches:

1. **Automated Testing** (`run_tests.sh`): Runs comprehensive tests automatically
2. **Manual Workflow** (`whole_game_real_world.Rmd`): Step-by-step analysis with your data

**Choose the manual workflow if you want to:**
- Understand each step of the analysis process
- Customize the analysis for your specific needs
- Learn how to use the package functions
- Generate custom visualizations and insights

**Choose automated testing if you want to:**
- Quickly validate that everything works with your data
- Run comprehensive tests for quality assurance
- Generate standardized reports

### Automatic Setup
The `setup.sh` script automatically:
- ✅ Validates environment security
- ✅ Checks R installation and packages
- ✅ Installs the zoomstudentengagement package
- ✅ Creates required directories
- ✅ Validates test data availability
- ✅ Runs data validation (if data is present)
- ✅ Sets up executable permissions

### Manual Setup
If you prefer manual setup:

1. **Copy infrastructure files**:
   ```bash
   cp scripts/real_world_testing/* my_testing_project/
   ```

2. **Create directories**:
   ```bash
   mkdir -p data/transcripts data/metadata reports outputs
   ```

3. **Make scripts executable**:
   ```bash
   chmod +x *.sh
   ```

4. **Install dependencies**:
   ```r
   install.packages(c("devtools", "testthat", "dplyr", "ggplot2", "lubridate"))
   devtools::install_local("..")  # If package is in parent directory
   ```

## 📊 Test Data Requirements

### Required Files

#### Transcript Files (`data/transcripts/`)
- **Format**: `.vtt`, `.txt`, or `.csv` files
- **Source**: Zoom recording exports
- **Content**: Real Zoom transcripts (anonymized)
- **Size**: Various file sizes for performance testing

#### Roster Data (`data/metadata/roster.csv`)
- **Format**: CSV file
- **Required columns**: Student names, IDs, course information
- **Content**: Student enrollment data (anonymized)
- **Purpose**: Name matching and validation

#### Session Metadata (`data/metadata/zoomus_recordings__*.csv`)
- **Format**: CSV files (Zoom export format)
- **Content**: Recording session information
- **Purpose**: Session mapping and validation

### Data Privacy Requirements

- **✅ Anonymized**: All names and identifiers should be anonymized
- **✅ No sensitive content**: Remove any sensitive discussion content
- **✅ Secure storage**: Store with proper access controls
- **✅ No real names**: Use placeholder names or anonymized IDs

## 🔍 Data Validation

The testing framework includes a data validation script that checks your test data before running tests.

### Running Validation
```bash
# Validate all data
./validate_data.sh

# Or run the R script directly
Rscript validate_data.R
```

### What Validation Checks
- **Transcript Files**: File format, readability, and content
- **Roster Data**: Required columns and data integrity
- **Session Metadata**: File structure and required fields
- **Privacy**: Potential sensitive content detection

## 🧪 Running Tests

### Quick Test Run
```bash
# Run all tests with default settings
./run_tests.sh
```

### Custom Test Run
```bash
# Run with custom output directory
Rscript run_real_world_tests.R --output-dir=my_reports --data-dir=data

# Run specific test scenarios
Rscript run_real_world_tests.R --scenario=performance --scenario=privacy
```

### Interactive Testing
```r
# Load the testing framework
source("run_real_world_tests.R")

# Run specific test functions
run_performance_tests()
run_privacy_tests()
run_functionality_tests()
```

## 📈 Test Scenarios

### 1. Core Functionality Testing
- **Transcript Processing**: Load and process real Zoom transcripts
- **Name Matching**: Test with actual student rosters
- **Metrics Calculation**: Validate engagement metrics
- **Visualization**: Test plotting functions with real data

### 2. Performance Testing
- **Large Files**: Test with transcript files >1MB
- **Batch Processing**: Test processing multiple files
- **Memory Usage**: Monitor memory consumption
- **Processing Time**: Measure performance characteristics

### 3. Error Handling & Edge Cases
- **Malformed Data**: Test with corrupted files
- **Missing Data**: Test with incomplete information
- **Empty Files**: Test with empty transcript files
- **Special Characters**: Test with unusual name formats

### 4. Privacy & Security Testing
- **Name Masking**: Verify privacy features
- **Data Anonymization**: Test anonymization capabilities
- **Secure Handling**: Validate secure file handling
- **Privacy-Conscious Outputs**: Test privacy-aware visualizations

## 📋 Test Results

### Generated Files
After running tests, you'll find:

- **`reports/test_report.md`**: Comprehensive test report
- **`reports/test_results.rds`**: Detailed results (R format)
- **`outputs/test_basic_plot.png`**: Sample visualization
- **`outputs/test_masked_plot.png`**: Privacy-conscious plot

### Success Criteria
- ✅ All tests complete successfully
- ✅ Performance within acceptable ranges
- ✅ Memory usage stays within limits
- ✅ No sensitive data exposure detected

### Failure Indicators
- ❌ Any test scenario fails
- ❌ Performance exceeds thresholds
- ❌ Memory problems or crashes
- ❌ Sensitive data exposed in outputs

## 🔒 Security Checklist

### Before Testing
- [ ] Verify secure, isolated environment
- [ ] Ensure test data is anonymized
- [ ] Set up logging controls
- [ ] Review data handling procedures

### During Testing
- [ ] Monitor for data exposure in logs
- [ ] Verify privacy features working
- [ ] Check no sensitive data cached
- [ ] Validate secure file handling

### After Testing
- [ ] Clean up test data and temp files
- [ ] Review logs for data exposure
- [ ] Document security concerns
- [ ] Update procedures if needed

## 🛠️ Troubleshooting

### Common Issues

#### Package Not Found
```bash
# Install from parent directory
Rscript -e "devtools::install_local('..')"
```

#### Missing Test Data
```bash
# Check data availability
ls -la data/transcripts/
ls -la data/metadata/
```

#### Permission Issues
```bash
# Make scripts executable
chmod +x *.sh
```

#### Environment Issues
```bash
# Check R installation
Rscript --version

# Check package availability
Rscript -e "library(zoomstudentengagement)"
```

### Getting Help

1. **Check logs**: Review console output for errors
2. **Verify data**: Ensure files are present and accessible
3. **Check permissions**: Verify file and directory permissions
4. **Review environment**: Ensure secure testing environment

## 🔄 Maintenance

### Updating the Testing Framework
```bash
# Update from the main repository
cp /path/to/updated/scripts/real_world_testing/* .

# Re-run setup
./setup.sh
```

### Adding New Test Scenarios
1. Edit `run_real_world_tests.R`
2. Add new test functions
3. Update `real_world_test_plan.md`
4. Test with real data
5. Update this README

### Data Management
- **Backup**: Regularly backup your test data
- **Cleanup**: Remove old test results periodically
- **Validation**: Verify data integrity regularly
- **Security**: Maintain access controls

## 📞 Support

For issues or questions:

1. **Check this README** for common solutions
2. **Review the test plan** in `real_world_test_plan.md`
3. **Check the main package documentation**
4. **Create an issue** in the main repository

## 📄 License

This testing framework is part of the `zoomstudentengagement` package and is subject to the same MIT license terms. 