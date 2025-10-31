cd services
for file in ./*; do
  if [ -x "$file" ]; then
    "./$file"
  fi
done
cd ..
while read -r module difficulty vuln; do
  ./preplant.sh $vuln
done < currentSet.txt
