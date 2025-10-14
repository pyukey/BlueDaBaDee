cd services
for file in ./*; do
  if [ -x "$file" ]; then
    "./$file"
  fi
done
cd ../preplants
./plant.sh
cd ..
