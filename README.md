# MARC Record Export

Exports MARC records for all collections created or updated within the provided date range

# How to use it

The plugin consists of one API POST call: POST /repositories/:repo_id/marc_export?modified_since={} , where 'modified_since' is a string formatted in Unix Epoch time. The plugin will grab the set of all Resource IDs created or modified after the time provided, then build a MARCXML Collection of those resources. 

Questions: kevin.clair [at] du.edu.
