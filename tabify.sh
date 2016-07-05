# Tabifies all the Haxe files
find . -name "*.hx" -exec bash -c 'unexpand -t 4 --first-only "$0" > tmp_tabz && mv tmp_tabz "$0"' {} \;