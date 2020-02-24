# Source-specific usage guide

## DmonHiro
### File structure
```
#|─────────────────────────────────────────────────────────────────────────────────────────|#
#| home/aurora/                                                                            |#
#|         └── Encodes/                                                                    |#
#|                 └── [DmonHiro] Girly Air Force (BD, 720p)/                              |#
#|                                        ├── 02 - I Call To You.mkv                       |#
#|                                        └── 02 - I Call To You.ass                       |#
#|─────────────────────────────────────────────────────────────────────────────────────────|#
```
#### Single file:
```
./animegrimoire-dmonhiro.sh '02 - I Call To You.mkv' 'Girly Air Force'
```

#### Batch:
```
for file in *.mkv; do animegrimoire-dmonhiro "$file" 'Girly Air Force'; done
```