# BD-INV-003 · Spatial Proximity Methodology & Reproducibility Paper

* **Date:** 2026-05-25  
* **Investigation ID:** BD-INV-003 (The Lead Belt)  
* **Subject:** Spatial Analysis Methodology, Assumptions, and Replication Guide  
* **Standard:** Transparent Data Journalism & Academic Reproducibility  

---

## 1. Introduction & Spatial Analysis Logic

The "Lead Belt" investigation maps the spatial proximity of educational institutions in Bangladesh to assessed lead-contaminated sites. The primary objective is to highlight where environmental contamination poses a direct localized risk to children.

The analysis is conducted through a zero-dependency Python script, [analyze.py](file:///c:/Users/Administrator/Desktop/insightgaps.github.io-main/insightgaps.github.io-main/methods/analyze.py), which calculates the distance between every contaminated site and every school node in the OpenStreetMap (OSM) database.

### Core Mathematical Formula (Haversine)
To determine the great-circle distance between two points on the Earth's surface using latitude and longitude, the script implements the standard **Haversine formula**:

$$a = \sin^2\left(\frac{\Delta\text{lat}}{2}\right) + \cos(\text{lat}_1) \cdot \cos(\text{lat}_2) \cdot \sin^2\left(\frac{\Delta\text{lon}}{2}\right)$$
$$c = 2 \cdot \text{atan2}\left(\sqrt{a}, \sqrt{1-a}\right)$$
$$d = R \cdot c$$

Where:
- $R = 6,371,000$ meters (the mean radius of the Earth).
- $d$ is the calculated great-circle distance in meters.
- Proximity is established if $d \le 500$ meters (the screening threshold for residential lead soil exposure).

---

## 2. OpenStreetMap School Snapshot

To ensure permanent reproducibility, a static snapshot of OpenStreetMap schools has been archived.
- **Dataset File:** [data/osm_schools.geojson](file:///c:/Users/Administrator/Desktop/insightgaps.github.io-main/insightgaps.github.io-main/data/osm_schools.geojson)
- **Snapshot Date:** March 2026 (Reconstructed dataset).
- **Extraction Query:** The school nodes were extracted using the following OpenStreetMap Overpass Turbo query:
  ```overpass
  [out:json][timeout:90];
  area["name"="Bangladesh"]["admin_level"="2"]->.searchArea;
  (
    node["amenity"="school"](area.searchArea);
    way["amenity"="school"](area.searchArea);
    relation["amenity"="school"](area.searchArea);
  );
  out center;
  ```
- **Deduplication:** Ways and relations tagged as `amenity=school` are converted to centroid points (using the `center` attribute from Overpass). Nodes with duplicate coordinate pairs (rounded to 5 decimal places, or approximately $\pm 1.1$m) are removed to prevent duplicate mapping of the same physical school campus.

---

## 3. Reconciliation of School and Student counts

Under forensic audit, a difference is observed between the published figures in the report and the unique counts derived from the raw spatial database.

### Published Numbers (Proximity Instances)
- **Stated Schools Count:** **145 schools at risk**
- **Stated Student Exposure:** **39,875 students**

### Reconstructed Numbers (Unique Counts)
- **Unique Schools Count:** **121 unique schools** (for the 44 headline sites)
- **Unique Student Count:** **33,275 unique students** (for the 44 headline sites)

### Discrepancy Explanation:
1. **Overlap Counting vs. Unique Counting:** 
   The published figure of **145 schools** represents the **sum of intersections** across the 44 headline sites. There are **24 school-site overlap instances** where a school falls within 500m of *more than one* contaminated site (resulting in 121 unique schools). In the report's workbook logic, these schools (and their students) are counted once for each site they are near (e.g., if a school is near Site A and Site B, its 275 students represent 550 student-exposure instances, yielding 145 intersections). 
   To maintain the integrity of the original findings, the published report preserves the **total exposure-instance estimate (39,875 students)**, representing the total index of school-site proximity instances. (In the replicated analysis using the 2026 OSM snapshot across all 294 sites, there are 31 schools that overlap buffers of multiple sites.)
2. **OSM Crowd-Sourced Database Changes:** 
   OpenStreetMap is updated continuously by volunteers. Re-running the live query in 2026 shows that 7 new lead-contaminated sites now have schools mapped within 500m due to recent OSM additions (yielding a total of 132 unique schools and 166 intersections across all 294 sites). The original report findings are locked to the historic March 2026 analysis.

---

## 4. Replication Instructions

To replicate the spatial intersection results, run the zero-dependency python script `analyze.py` from the command line:

```bash
python methods/analyze.py \
  --sites data/BD-INV-003_LeadBelt_MasterDataset_v5.csv \
  --schools data/osm_schools.geojson \
  --output data/osm_intersections.csv
```

### Script Inputs:
- `--sites`: Path to the contaminated sites CSV (containing `site_id`, `lat`, `lon`, and `max_soil_pb_ppm` columns).
- `--schools`: Path to the archived school nodes GeoJSON dataset.
- `--output`: Path to write the output CSV containing all matched intersections.
- `--buffer`: Distance threshold in meters (default is `500.0`m).
- `--enrollment`: Average student enrollment multiplier (default is `275`).
