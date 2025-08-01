# Real-World Testing Infrastructure for zoomstudentengagement

This directory contains the testing infrastructure for validating the `zoomstudentengagement` package with real confidential data in a production-like environment.

## ⚠️ **SECURITY WARNING**

**IMPORTANT**: This testing involves real student data and should be conducted in a secure, isolated environment. 

- **DO NOT** run these tests in Cursor, GitHub Codespaces, or other LLM/IDE environments
- **DO NOT** commit or share any test results containing sensitive information
- **DO** use a secure terminal or isolated environment
- **DO** ensure data privacy and confidentiality are maintained

## Directory Structure

```
scripts/real_world_testing/           # This directory (infrastructure only)
├── run_real_world_tests.R            # Main testing script
├── run_tests.sh                      # Test runner script
├── real_world_test_plan.md           # Comprehensive testing plan
└── README.md                         # This file

zoom_real_world_testing/              # Actual test data (gitignored)
├── data/                             # Test data (confidential)
│   ├── transcripts/                  # Real Zoom transcript files
│   └── metadata/                     # Student roster and session data
├── reports/                          # Test results and outputs
├── outputs/                          # Generated files and plots
└── test_config.rds                   # Test configuration
```

## Setup Instructions

### 1. Create Test Environment

Create the actual testing directory (this is gitignored for security):

```zsh
# From the project root
mkdir -p zoom_real_world_testing/data/transcripts
mkdir -p zoom_real_world_testing/data/metadata
mkdir -p zoom_real_world_testing/reports
mkdir -p zoom_real_world_testing/outputs
```

### 2. Copy Infrastructure Files

Copy the testing infrastructure to the actual test directory:

```zsh
# From the project root
cp scripts/real_world_testing/run_real_world_tests.R zoom_real_world_testing/
cp scripts/real_world_testing/run_tests.sh zoom_real_world_testing/
cp scripts/real_world_testing/real_world_test_plan.md zoom_real_world_testing/
chmod +x zoom_real_world_testing/run_tests.sh
```

### 3. Add Test Data

Place your real test data in the appropriate directories:

- **Transcript files**: `zoom_real_world_testing/data/transcripts/`
- **Roster data**: `zoom_real_world_testing/data/metadata/roster.csv`
- **Session metadata**: `zoom_real_world_testing/data/metadata/zoomus_recordings__*.csv`

## Quick Start

### Prerequisites

1. **Secure Environment**: Use a secure terminal outside of LLM environments
2. **R Installation**: Ensure R and required packages are installed
3. **Package Installation**: Install the `zoomstudentengagement` package
4. **Test Data**: Ensure real test data is available in the `zoom_real_world_testing/data/` directory

### Running Tests

#### Option 1: Using the Shell Script (Recommended)

```zsh
cd zoom_real_world_testing
./run_tests.sh
```

#### Option 2: Direct R Script Execution

```zsh
cd zoom_real_world_testing
Rscript run_real_world_tests.R --output-dir=reports --data-dir=data
```

#### Option 3: Interactive R Session

```r
# Load the testing script
source("run_real_world_tests.R")

# Run tests interactively
run_all_tests()
```

## Test Scenarios

The testing framework covers the following scenarios:

### 1. Core Functionality Testing
- **Transcript Processing**: Load and process real Zoom transcripts
- **Name Matching**: Test name matching with actual student rosters
- **Metrics Calculation**: Validate engagement metrics calculations
- **Visualization**: Test plotting functions with real data

### 2. Performance Testing
- **Large Files**: Test with transcript files >1MB
- **Batch Processing**: Test processing multiple files
- **Memory Usage**: Monitor memory consumption
- **Processing Time**: Measure performance characteristics

### 3. Error Handling & Edge Cases
- **Malformed Data**: Test with corrupted or incomplete files
- **Missing Data**: Test with missing roster information
- **Empty Files**: Test with empty transcript files
- **Special Characters**: Test with unusual name formats

### 4. Privacy & Security Testing
- **Name Masking**: Verify privacy features work correctly
- **Data Anonymization**: Test data anonymization capabilities
- **Secure Handling**: Validate secure file handling practices
- **Privacy-Conscious Outputs**: Test privacy-aware visualizations

## Test Data Requirements

### Required Files

1. **Transcript Files** (`zoom_real_world_testing/data/transcripts/`)
   - Real Zoom `.transcript.vtt` files
   - Multiple files for batch testing
   - Various file sizes for performance testing

2. **Roster Data** (`zoom_real_world_testing/data/metadata/roster.csv`)
   - Student enrollment information (anonymized)
   - Name matching data for validation
   - Course and section information

3. **Session Metadata** (`zoom_real_world_testing/data/metadata/`)
   - Zoom recording session information
   - File metadata and timestamps
   - Recording quality information

### Data Privacy

- **Anonymization**: All test data should be properly anonymized
- **No Real Names**: Use placeholder names or anonymized identifiers
- **No Sensitive Content**: Ensure no sensitive discussion content is included
- **Secure Storage**: Store test data securely with proper access controls

## Test Results

### Output Files

After running tests, the following files will be generated:

1. **`zoom_real_world_testing/reports/test_report.md`**: Comprehensive test report in Markdown format
2. **`zoom_real_world_testing/reports/test_results.rds`**: Detailed test results in R format
3. **`zoom_real_world_testing/reports/test_basic_plot.png`**: Sample visualization (no sensitive data)
4. **`zoom_real_world_testing/reports/test_masked_plot.png`**: Privacy-conscious visualization

### Interpreting Results

#### Success Criteria
- **All Tests Pass**: All test scenarios complete successfully
- **Performance Acceptable**: Processing times within expected ranges
- **Memory Usage Reasonable**: Memory consumption stays within limits
- **No Privacy Issues**: No sensitive data exposure detected

#### Failure Indicators
- **Test Failures**: Any test scenario fails to complete
- **Performance Issues**: Processing times exceed acceptable thresholds
- **Memory Problems**: Excessive memory usage or crashes
- **Privacy Violations**: Sensitive data exposed in outputs or logs

## Security Checklist

### Before Testing
- [ ] Verify test environment is secure and isolated
- [ ] Ensure test data is properly anonymized
- [ ] Set up logging controls to prevent data exposure
- [ ] Review data handling procedures

### During Testing
- [ ] Monitor for any data exposure in logs or outputs
- [ ] Verify privacy features are working correctly
- [ ] Check that no sensitive data is cached or stored
- [ ] Validate secure file handling practices

### After Testing
- [ ] Clean up any test data and temporary files
- [ ] Review logs for any potential data exposure
- [ ] Document any security concerns found
- [ ] Update security procedures if needed

## Troubleshooting

### Common Issues

1. **Package Not Found**
   ```bash
   # Install the package first
   Rscript -e "devtools::install_local('..')"
   ```

2. **Missing Test Data**
   ```zsh
   # Ensure test data is available
   ls -la zoom_real_world_testing/data/transcripts/
   ls -la zoom_real_world_testing/data/metadata/
   ```

3. **Permission Issues**
   ```zsh
   # Make script executable
   chmod +x zoom_real_world_testing/run_tests.sh
   ```

4. **Environment Issues**
   ```zsh
   # Check R installation
   Rscript --version
   
   # Check package availability
   Rscript -e "library(zoomstudentengagement)"
   ```

### Getting Help

If you encounter issues:

1. **Check the logs**: Review console output for error messages
2. **Verify data**: Ensure test data files are present and accessible
3. **Check permissions**: Verify file and directory permissions
4. **Review environment**: Ensure you're in a secure testing environment

## Contributing

When contributing to the testing framework:

1. **Follow Security Guidelines**: Always prioritize data privacy
2. **Document Changes**: Update this README and test plan
3. **Test Thoroughly**: Validate changes with real data
4. **Review Outputs**: Ensure no sensitive information is exposed

## License

This testing framework is part of the `zoomstudentengagement` package and is subject to the same MIT license terms. 