# Troubleshooting Guide for zoomstudentengagement

## 🔧 Common Issues and Solutions

This guide helps you resolve common issues when using the zoomstudentengagement workflow.

### Package Installation Issues

**Issue: "Package not found" or "Could not find function"**
```
Error: could not find function "read_lookup_safely"
```

**Solution:**
1. Reinstall the package:
   ```r
   devtools::install_github("revgizmo/zoomstudentengagement")
   ```
2. Restart your R session
3. Load the package:
   ```r
   library(zoomstudentengagement)
   ```

**Issue: Package installation fails**
```
Error: Failed to install package
```

**Solution:**
1. Update R to the latest version
2. Install required dependencies:
   ```r
   install.packages(c("devtools", "dplyr", "ggplot2", "readr", "tibble", "lubridate", "jsonlite"))
   ```
3. Try installation again

### Data File Issues

**Issue: "No transcript files found"**
```
Warning: No transcript files found in data/transcripts/
```

**Solution:**
1. Check file extensions - only `.transcript.vtt` files are processed
2. Verify file location: `data/transcripts/`
3. Check file permissions
4. Ensure files are not corrupted

**Issue: "Invalid VTT file"**
```
Error: Invalid VTT: expected 'WEBVTT', got '...'
```

**Solution:**
1. Verify the file is a valid Zoom transcript (not closed captions)
2. Check file encoding (should be UTF-8)
3. Try opening the file in a text editor to verify format

**Issue: "Roster file not found"**
```
Warning: Roster file not found at: data/metadata/roster.csv
```

**Solution:**
1. Create the roster file:
   ```csv
   preferred_name,formal_name,student_id
   John Smith,John Smith,STU001
   Jane Doe,Jane Doe,STU002
   ```
2. Ensure correct column names
3. Check file permissions

### Privacy and Configuration Issues

**Issue: "Real names found in output"**
```
Warning: Real names found in final output
```

**Solution:**
1. Check privacy level setting:
   ```r
   set_privacy_defaults("ferpa_standard")
   ```
2. Verify privacy level in workflow parameters
3. Re-run the workflow with appropriate privacy settings

**Issue: "Instructor not found in transcript"**
```
Warning: Configured instructors not found in transcript
```

**Solution:**
1. Check instructor name variations in `section_names_lookup.csv`
2. Add common variations (e.g., "Dr. Smith", "Professor Smith", "Smith")
3. Verify the instructor name parameter matches transcript names

### Workflow Execution Issues

**Issue: "Workflow fails silently"**
```
No error message, but no output files generated
```

**Solution:**
1. Check console output for warnings
2. Verify all required files exist
3. Check R session for errors
4. Run with verbose logging:
   ```r
   options(verbose = TRUE)
   ```

**Issue: "Memory issues with large datasets"**
```
Error: cannot allocate vector of size...
```

**Solution:**
1. Process sessions in smaller batches
2. Increase R memory limit:
   ```r
   memory.limit(size = 8000)  # Windows
   ```
3. Use incremental processing mode
4. Close other applications to free memory

**Issue: "Session tracking issues"**
```
Warning: Session already processed
```

**Solution:**
1. Check `data/metadata/session_tracking.csv`
2. Use `incremental_mode = FALSE` to reprocess all sessions
3. Delete session tracking file to reset:
   ```bash
   rm data/metadata/session_tracking.csv
   ```

### Performance Issues

**Issue: "Workflow runs very slowly"**
```
Processing takes much longer than expected
```

**Solution:**
1. Check file sizes - large transcript files take longer
2. Use incremental processing to avoid reprocessing
3. Process sessions in smaller batches
4. Check system resources (CPU, memory, disk)

**Issue: "Large output files"**
```
Output files are much larger than expected
```

**Solution:**
1. Check privacy settings - unmasked data is larger
2. Review transcript file sizes
3. Consider filtering data before processing
4. Use appropriate privacy levels

### File Permission Issues

**Issue: "Cannot write to output directory"**
```
Error: cannot open file for writing
```

**Solution:**
1. Check directory permissions
2. Ensure directories exist:
   ```r
   dir.create("outputs", recursive = TRUE)
   dir.create("reports", recursive = TRUE)
   ```
3. Check disk space
4. Run with appropriate user permissions

**Issue: "Cannot read input files"**
```
Error: cannot open file for reading
```

**Solution:**
1. Check file permissions
2. Verify file paths are correct
3. Ensure files are not locked by other applications
4. Check file encoding

### R Markdown Specific Issues

**Issue: "R Markdown rendering fails"**
```
Error: pandoc document conversion failed
```

**Solution:**
1. Install pandoc:
   ```r
   install.packages("rmarkdown")
   ```
2. Check R Markdown dependencies
3. Verify output format is supported
4. Try rendering with different options

**Issue: "Chunk execution fails"**
```
Error: chunk execution failed
```

**Solution:**
1. Check chunk dependencies
2. Verify all required packages are loaded
3. Check for syntax errors in chunks
4. Run chunks individually to isolate issues

### Debugging Tips

**Enable verbose logging:**
```r
options(verbose = TRUE)
options(warn = 1)  # Convert warnings to errors
```

**Check package version:**
```r
packageVersion("zoomstudentengagement")
```

**Validate data files:**
```r
# Check transcript file
file.exists("data/transcripts/your_file.transcript.vtt")

# Check roster file
file.exists("data/metadata/roster.csv")

# Check lookup file
file.exists("data/metadata/section_names_lookup.csv")
```

**Test individual functions:**
```r
# Test transcript loading
test_data <- load_zoom_transcript("path/to/transcript.vtt")

# Test roster loading
roster <- load_roster("data/metadata", "roster.csv")

# Test privacy settings
set_privacy_defaults("ferpa_standard")
```

### Getting Additional Help

**Check package documentation:**
```r
?zoomstudentengagement
?summarize_transcript_metrics
?classify_participants
```

**Review workflow logs:**
- Check console output for detailed messages
- Review generated log files
- Check session tracking for processing history

**Common debugging commands:**
```r
# Check loaded packages
(.packages())

# Check working directory
getwd()

# List files in directory
list.files("data/transcripts")

# Check object structure
str(your_object)
```

### Prevention Tips

1. **Always validate your data** before running the workflow
2. **Use appropriate privacy settings** for your use case
3. **Keep backups** of your original data files
4. **Test with small datasets** before processing large files
5. **Monitor system resources** during processing
6. **Document your configuration** for reproducibility

### Emergency Recovery

**If the workflow fails completely:**

1. **Check the session tracking file** to see what was processed
2. **Backup your data** before making changes
3. **Reset the workflow state:**
   ```bash
   rm data/metadata/session_tracking.csv
   rm data/metadata/workflow_config.json
   ```
4. **Start with a fresh run** using `incremental_mode = FALSE`

**If output files are corrupted:**

1. **Check the backup files** created by the workflow
2. **Re-run the workflow** with the same parameters
3. **Use session tracking** to identify which sessions need reprocessing

Remember: The workflow is designed to be robust and recoverable. Most issues can be resolved by following these troubleshooting steps.
