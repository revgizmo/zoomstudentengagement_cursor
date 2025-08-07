# AI Research Prompts for Ethical Issues Analysis
*Optimized prompts for ChatGPT and Google Gemini Deep Research*

**Date**: August 2025  
**Purpose**: Get comprehensive research on ethical issues for zoomstudentengagement R package

---

## 🤖 ChatGPT Deep Research Prompt

```
I'm developing an R package called "zoomstudentengagement" for analyzing student engagement from Zoom transcripts. I have FOUR CRITICAL ETHICAL ISSUES that are CRAN submission blockers and need immediate technical solutions.

**CONTEXT**: This is an R package for educational researchers and instructors to analyze student participation patterns from Zoom transcripts. The goal is equitable participation, not surveillance.

**CRITICAL ISSUES**:

1. **Issue #125: Privacy-First Defaults and Data Anonymization**
   - Need: All functions must default to anonymized output
   - Problem: Currently exposes student names by default
   - Required: `privacy_level` parameter (full, partial, individual, none), automatic name masking

2. **Issue #126: FERPA Compliance Features**
   - Need: Built-in FERPA compliance for educational software
   - Problem: No data retention controls, secure deletion, consent tracking
   - Required: Data retention, secure deletion, audit logging, consent tracking

3. **Issue #84: Security Compliance**
   - Need: Secure data handling and input validation
   - Problem: Potential vulnerabilities in data processing
   - Required: Input validation, secure file handling, security documentation

4. **Issue #85: Ethical Use Guidelines**
   - Need: Ensure equitable participation focus, not surveillance
   - Problem: Functions could be misused for surveillance
   - Required: Ethical guidelines, bias assessment, positive outcomes focus

**WHAT I NEED**:

1. **Technical Implementation Details**:
   - R code examples for privacy-first design
   - Step-by-step implementation guide for each issue
   - Specific FERPA compliance requirements for R packages
   - Security best practices for educational data

2. **Concrete Solutions**:
   - Code for `set_privacy_defaults()` function
   - Implementation of `privacy_level` parameters (full, partial, individual, none)
   - Data retention and deletion functions
   - Audit logging implementation
   - Input validation patterns

3. **Recent Developments** (2023-2025):
   - Latest FERPA requirements for educational software
   - New privacy-preserving techniques for R
   - Recent security vulnerabilities in educational tools
   - Updated ethical guidelines for student data analysis

4. **Implementation Roadmap**:
   - 2-week timeline with daily tasks
   - Testing strategies for each feature
   - Validation approaches for compliance
   - Potential pitfalls and how to avoid them

**FORMAT**: Please provide actionable technical solutions with R code examples, specific requirements, and implementation steps. Focus on practical, implementable solutions that can be coded immediately.
```

---

## 🔍 Google Gemini Deep Research Prompt

```
I'm conducting comprehensive research on ethical and legal requirements for educational software that analyzes student data. I need detailed research on FOUR CRITICAL AREAS for an R package called "zoomstudentengagement."

**RESEARCH CONTEXT**: 
- R package for analyzing Zoom transcript data for student engagement
- Target users: Educational researchers and instructors
- Goal: Equitable participation analysis, not surveillance
- CRAN submission requirements (R package repository)

**RESEARCH AREAS**:

1. **FERPA Compliance for Educational Software (2023-2025)**
   - Current FERPA requirements for software that processes student data
   - Data retention requirements for educational institutions
   - Consent tracking and audit logging requirements
   - Legal precedents and case studies
   - Recent changes in FERPA regulations

2. **Student Privacy Rights in Educational Technology**
   - Privacy rights for students in online learning environments
   - Institutional review board (IRB) requirements for educational software
   - Best practices for student data anonymization
   - Privacy-preserving data analysis techniques
   - Recent legal cases involving student data privacy

3. **Ethical Frameworks for Educational Data Analysis**
   - Surveillance vs. equitable participation frameworks
   - Ethical guidelines for student engagement analysis
   - Bias assessment in educational technology
   - Student agency and consent in data analysis
   - Best practices for ethical educational software

4. **Security Requirements for Educational Data**
   - Security standards for educational software
   - Data protection requirements for student information
   - Input validation and sanitization best practices
   - Secure file handling in educational contexts
   - Recent security incidents in educational technology

**WHAT I NEED**:

1. **Comprehensive Research Summary**:
   - Current legal requirements and recent changes
   - Institutional policy examples and case studies
   - Ethical framework recommendations
   - Security best practices and standards

2. **Implementation Guidance**:
   - Specific requirements for R packages
   - Institutional adoption strategies
   - Compliance validation approaches
   - Risk assessment frameworks

3. **Recent Developments** (2023-2025):
   - Updated FERPA guidance and interpretations
   - New privacy regulations affecting educational software
   - Recent legal cases and their implications
   - Emerging ethical frameworks and guidelines

4. **Academic Sources and Citations**:
   - Peer-reviewed research on educational privacy
   - Legal analysis and precedents
   - Institutional policy documents
   - Government guidance and regulations

**FORMAT**: Please provide comprehensive research summaries with detailed citations, specific requirements, and implementation guidance. Focus on authoritative sources and recent developments.
```

---

## 🚀 **PHASE 2: Technical Implementation Prompts**

### **🤖 ChatGPT Phase 2 Prompt**

```
I'm implementing the technical solutions for ethical issues in the zoomstudentengagement R package. Phase 1 provided the legal foundation - now I need detailed technical implementation guidance.

**PHASE 1 FOUNDATION**:
- FERPA compliance requirements established
- Privacy-first design with four levels (full, partial, individual, none)
- User-controlled file model (no secure_delete needed)
- Audit logging facilitation approach
- Shared responsibility model for compliance

**TECHNICAL IMPLEMENTATION NEEDS**:

1. **Privacy Level Implementation**:
   - Specific R code for implementing privacy_level parameter across all 40+ functions
   - How to handle the "individual" privacy level (one student unmasked, others masked)
   - Performance optimization for privacy features
   - Backward compatibility strategies

2. **Global Privacy Infrastructure**:
   - Implementation of `set_privacy_defaults()` function
   - How to manage global settings with function-level overrides
   - User interface design for privacy controls
   - Configuration persistence and management

3. **Security Implementation**:
   - Input validation patterns for Zoom transcript formats
   - Data sanitization for transcript content
   - File path security and validation
   - Temp file leak prevention with `on.exit(unlink(tmp))`

4. **Audit Logging Facilitation**:
   - Implementation of optional `log_activity = TRUE` parameter
   - Metadata-only logging approach
   - User-friendly logging format and documentation
   - Testing strategies for logging features

5. **Testing and Validation**:
   - Specific test cases for privacy features
   - Performance benchmarking for privacy operations
   - Compliance testing procedures
   - User experience testing approaches

**WHAT I NEED**:

1. **Detailed Code Examples**:
   - Complete R function implementations
   - Error handling and edge cases
   - Performance optimization techniques
   - Testing code and validation procedures

2. **Implementation Strategy**:
   - Step-by-step implementation order
   - Migration strategy for existing users
   - Rollback and debugging procedures
   - Documentation requirements

3. **Performance Considerations**:
   - Memory usage optimization
   - Computational overhead assessment
   - Scalability for large transcript datasets
   - Benchmarking approaches

4. **User Experience Design**:
   - Intuitive privacy control interfaces
   - Clear error messages and guidance
   - Documentation and training materials
   - Accessibility considerations

**FORMAT**: Please provide detailed technical solutions with complete R code examples, implementation strategies, and testing approaches. Focus on practical, production-ready code that can be implemented immediately.
```

### **🔍 Google Gemini Phase 2 Prompt**

```
I'm implementing technical solutions for ethical issues in educational software. Phase 1 established legal requirements - now I need technical implementation guidance focused on institutional compliance and adoption.

**PHASE 1 FOUNDATION**:
- FERPA compliance framework established
- User-controlled file model with shared responsibility
- Institutional adoption requirements identified
- CRAN policy alignment requirements

**TECHNICAL IMPLEMENTATION NEEDS**:

1. **Institutional Compliance Features**:
   - Technical features needed to support institutional review processes
   - Compliance validation and testing procedures
   - Documentation requirements for institutional adoption
   - Multi-stakeholder review support features

2. **FERPA Implementation Details**:
   - Technical implementation of "school official" exception support
   - Consent tracking features for user-controlled model
   - Data retention control implementation
   - Audit trail facilitation for institutional compliance

3. **Security and Privacy Technologies**:
   - Advanced privacy-preserving techniques for educational data
   - Differential Privacy implementation for aggregate reporting
   - k-Anonymity and other formal privacy models
   - Bias detection and mitigation tools

4. **Documentation and Training**:
   - Technical documentation for institutional review
   - User training materials for privacy features
   - Compliance validation guides
   - Risk assessment frameworks

5. **Testing and Validation**:
   - Compliance testing procedures
   - Privacy guarantee validation
   - Institutional adoption testing
   - Performance and security testing

**WHAT I NEED**:

1. **Institutional Adoption Strategy**:
   - Technical features that support institutional review
   - Compliance validation procedures
   - Documentation requirements for different institution types
   - Risk assessment and mitigation approaches

2. **Advanced Privacy Technologies**:
   - Implementation guidance for Differential Privacy
   - k-Anonymity and other formal privacy models
   - Bias detection and mitigation techniques
   - Future-proofing for evolving regulations

3. **Compliance Testing**:
   - Specific testing procedures for FERPA compliance
   - Privacy guarantee validation methods
   - Institutional review support features
   - Performance and security testing approaches

4. **Documentation Framework**:
   - Technical documentation structure
   - User training material requirements
   - Compliance validation guides
   - Institutional adoption support materials

**FORMAT**: Please provide comprehensive technical guidance with specific implementation requirements, testing procedures, and documentation frameworks. Focus on institutional compliance and adoption support.
```

---

## 📋 **Phase 2 Research Strategy**

### **Dual-Platform Approach**
- **ChatGPT**: Focus on practical R code implementation and user experience
- **Google Gemini**: Focus on institutional compliance and advanced privacy technologies
- **Synthesis**: Combine technical implementation with compliance requirements

### **Expected Outcomes**
1. **Detailed Implementation Code**: Complete R functions with privacy features
2. **Testing Frameworks**: Comprehensive testing procedures for all features
3. **Documentation Structure**: Technical and user documentation requirements
4. **Institutional Support**: Features and documentation for institutional adoption

### **Success Criteria**
- [ ] Complete technical implementation plan
- [ ] Production-ready code examples
- [ ] Comprehensive testing strategy
- [ ] Institutional adoption support
- [ ] Documentation framework

---

**Next Phase**: Phase 3 - Ethical Framework and Bias Assessment 