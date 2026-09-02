#!/usr/bin/env python3
"""
BD-INV-003 The Lead Belt — Spatial Proximity Analysis Script
Author: Insight Gaps Bureau
License: CC BY 4.0

This script reconstructs the spatial intersection workflow used to calculate 
the proximity of school nodes to assessed lead-contaminated sites in Bangladesh.
It relies entirely on Python's standard library to ensure full portability and
zero-dependency replication.

================================================================================
WORKFLOW SPECIFICATION
================================================================================

1. INPUTS:
   - Contaminated Sites: A CSV file containing geocoded contamination sites 
     (columns: site_id, lat/latitude, lon/longitude/lng, max_soil_pb_ppm).
   - School Nodes: An OSM data export in either GeoJSON or Overpass JSON format
     containing amenity=school nodes (must contain coordinates and optional names).
   - Configuration Parameters: Spatial buffer threshold (default 500m), 
     enrollment multiplier (default 275 students/school).

2. PROCESSING STEPS:
   - Parse contaminated sites CSV, mapping coordinate and ID headers dynamically.
   - Load and parse OpenStreetMap school data, detecting input format (GeoJSON/JSON) 
     and extracting deduplicated point centroids.
   - Loop over all sites and calculate the Haversine distance to each school node.
   - Intersect any site-school pairs falling within the buffer zone.
   - Aggregate statistics: unique schools exposed, total sites with school overlaps, 
     and estimated student exposure bounds.

3. SPATIAL INTERSECTION LOGIC:
   - Great-circle distance calculation via the Haversine formula:
     a = sin²(Δlat/2) + cos(lat₁) * cos(lat₂) * sin²(Δlon/2)
     c = 2 * atan2(√a, √(1-a))
     d = R * c
     Where R = 6,371,000 meters (mean Earth radius).
   - If distance d <= buffer_threshold, record the intersection.

4. OUTPUTS:
   - Standard Out: High-level statistics summary matching the BD-INV-003 findings.
   - Output CSV: Detail file mapping each toxic site to its adjacent schools 
     with coordinates, soil lead levels, and calculated distance in meters.
================================================================================
"""

import os
import sys
import math
import json
import csv
import argparse

# Earth's mean radius in meters
EARTH_RADIUS_METERS = 6371000

def haversine(lat1, lon1, lat2, lon2):
    """
    Calculate the great-circle distance between two points on the Earth's surface
    using the Haversine formula. Returns the distance in meters.
    """
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)
    
    a = (math.sin(dphi / 2.0) ** 2 + 
         math.cos(phi1) * math.cos(phi2) * (math.sin(dlambda / 2.0) ** 2))
    
    c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
    return EARTH_RADIUS_METERS * c

def load_sites(csv_path):
    """
    Loads contaminated sites from a CSV file. Identifies coordinate columns
    dynamically based on common header names.
    """
    if not os.path.exists(csv_path):
        print(f"Error: Contaminated sites file not found at {csv_path}", file=sys.stderr)
        sys.exit(1)
        
    sites = []
    with open(csv_path, mode='r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        
        # Lowercase headers to map columns robustly
        headers = {h.lower().strip(): h for h in reader.fieldnames}
        
        id_col = next((headers[k] for k in ['site_id', 'id', 'siteid', 'i'] if k in headers), None)
        lat_col = next((headers[k] for k in ['lat', 'latitude', 'la'] if k in headers), None)
        lon_col = next((headers[k] for k in ['lon', 'longitude', 'lng', 'lo'] if k in headers), None)
        lead_col = next((headers[k] for k in ['max_soil_pb_ppm', 'soil_lead_ppm', 'lead_ppm', 'lead', 'p'] if k in headers), None)
        
        if not lat_col or not lon_col:
            print(f"Error: Could not identify latitude/longitude columns in CSV. Fieldnames: {reader.fieldnames}", file=sys.stderr)
            sys.exit(1)
            
        for line_num, row in enumerate(reader, start=1):
            try:
                site_id = row[id_col] if id_col else f"SITE_{line_num}"
                lat = float(row[lat_col])
                lon = float(row[lon_col])
                lead_ppm = float(row[lead_col]) if (lead_col and row[lead_col].strip()) else 0.0
                
                sites.append({
                    'site_id': site_id,
                    'lat': lat,
                    'lon': lon,
                    'lead_ppm': lead_ppm,
                    'raw_row': row
                })
            except ValueError as e:
                print(f"Warning: Skipping row {line_num} due to formatting error: {e}", file=sys.stderr)
                
    return sites

def load_schools(file_path):
    """
    Loads OpenStreetMap school nodes. Detects whether the file is in GeoJSON format
    or standard Overpass API JSON format.
    """
    if not os.path.exists(file_path):
        print(f"Error: OSM schools file not found at {file_path}", file=sys.stderr)
        sys.exit(1)
        
    schools = []
    
    with open(file_path, mode='r', encoding='utf-8') as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError as e:
            print(f"Error parsing JSON from {file_path}: {e}", file=sys.stderr)
            sys.exit(1)
            
    # Format 1: GeoJSON
    if isinstance(data, dict) and data.get('type') == 'FeatureCollection':
        features = data.get('features', [])
        for f in features:
            geom = f.get('geometry', {})
            props = f.get('properties', {})
            
            if geom and geom.get('type') == 'Point':
                coords = geom.get('coordinates', [])
                if len(coords) >= 2:
                    lon, lat = float(coords[0]), float(coords[1])
                    school_id = f.get('id', props.get('osm_id', f"OSM_{len(schools)}"))
                    name = props.get('name', 'Unnamed School')
                    
                    schools.append({
                        'school_id': school_id,
                        'name': name,
                        'lat': lat,
                        'lon': lon
                    })
                    
    # Format 2: Overpass JSON (elements array)
    elif isinstance(data, dict) and 'elements' in data:
        elements = data.get('elements', [])
        for elem in elements:
            # Overpass elements can be nodes, ways, or relations.
            # Nodes have lat/lon directly; center is used for ways/relations if queries with "out center".
            lat = elem.get('lat') or (elem.get('center', {}).get('lat') if 'center' in elem else None)
            lon = elem.get('lon') or (elem.get('center', {}).get('lon') if 'center' in elem else None)
            
            if lat is not None and lon is not None:
                school_id = elem.get('id')
                tags = elem.get('tags', {})
                name = tags.get('name', 'Unnamed School')
                
                schools.append({
                    'school_id': f"node/{school_id}" if elem.get('type') == 'node' else f"{elem.get('type')}/{school_id}",
                    'name': name,
                    'lat': float(lat),
                    'lon': float(lon)
                })
    else:
        print("Error: Unrecognized school data format. Must be GeoJSON or Overpass JSON.", file=sys.stderr)
        sys.exit(1)
        
    return schools

def run_proximity_analysis(sites, schools, buffer_meters, enrollment_multiplier):
    """
    Computes distances between all sites and schools. Collects pairs within the buffer.
    """
    intersections = []
    sites_with_schools = set()
    schools_exposed = set()
    
    for s in sites:
        for sch in schools:
            dist = haversine(s['lat'], s['lon'], sch['lat'], sch['lon'])
            if dist <= buffer_meters:
                intersections.append({
                    'site_id': s['site_id'],
                    'site_lat': s['lat'],
                    'site_lon': s['lon'],
                    'site_lead_ppm': s['lead_ppm'],
                    'school_id': sch['school_id'],
                    'school_name': sch['name'],
                    'school_lat': sch['lat'],
                    'school_lon': sch['lon'],
                    'distance_meters': round(dist, 2)
                })
                sites_with_schools.add(s['site_id'])
                schools_exposed.add(sch['school_id'])
                
    return intersections, sites_with_schools, schools_exposed

def main():
    parser = argparse.ArgumentParser(
        description="Replicate spatial intersection between contaminated sites and OSM schools."
    )
    parser.add_argument('--sites', required=True, help="Path to contaminated sites CSV.")
    parser.add_argument('--schools', required=True, help="Path to OSM schools JSON/GeoJSON.")
    parser.add_argument('--output', required=True, help="Path to write output intersections CSV.")
    parser.add_argument('--buffer', type=float, default=500.0, help="Spatial buffer distance in meters (default: 500).")
    parser.add_argument('--enrollment', type=int, default=275, help="Central enrollment estimate per school (default: 275).")
    
    args = parser.parse_args()
    
    print("----------------------------------------------------------------")
    print("BD-INV-003 Lead Belt Replication Tool")
    print("----------------------------------------------------------------")
    print(f"Loading contamination sites: {args.sites}")
    sites = load_sites(args.sites)
    print(f"Loaded {len(sites)} sites.")
    
    print(f"Loading school locations: {args.schools}")
    schools = load_schools(args.schools)
    print(f"Loaded {len(schools)} school nodes.")
    
    print(f"Running intersection (buffer: {args.buffer}m, enrollment multiplier: {args.enrollment})...")
    intersections, sites_with_schools, schools_exposed = run_proximity_analysis(
        sites, schools, args.buffer, args.enrollment
    )
    
    # Calculate statistics matching findings
    num_sites_hit = len(sites_with_schools)
    num_schools_hit = len(schools_exposed)
    est_students_exposure = num_schools_hit * args.enrollment
    
    lower_bound = num_schools_hit * 170
    upper_bound = num_schools_hit * 350
    
    print("\n========================= ANALYSIS RESULTS =====================")
    print(f"Contaminated sites with schools within {args.buffer}m: {num_sites_hit}")
    print(f"Total schools falling within buffers: {num_schools_hit}")
    print(f"Estimated student exposure (central multiplier {args.enrollment}): {est_students_exposure:,}")
    print(f"Exposure bounds: Lower (170/school): {lower_bound:,} | Upper (350/school): {upper_bound:,}")
    print("================================================================\n")
    
    # Write output intersections CSV
    print(f"Writing detailed output report to: {args.output}")
    output_dir = os.path.dirname(args.output)
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir, exist_ok=True)
        
    with open(args.output, mode='w', encoding='utf-8', newline='') as f:
        writer = csv.writer(f)
        writer.writerow([
            'site_id', 'site_latitude', 'site_longitude', 'max_soil_lead_ppm',
            'school_id', 'school_name', 'school_latitude', 'school_longitude',
            'distance_meters'
        ])
        for row in intersections:
            writer.writerow([
                row['site_id'], row['site_lat'], row['site_lon'], row['site_lead_ppm'],
                row['school_id'], row['school_name'], row['school_lat'], row['school_lon'],
                row['distance_meters']
            ])
            
    print("Analysis complete.")

if __name__ == "__main__":
    main()
