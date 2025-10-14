cd ../services
for file in ./*; do
  if [ -x "$file" ]; then
    "./$file"
  fi
done
cd ..

cd preplants
./plant.sh
