cd preplants
./plant.sh
cd ../services
for file in ./*; do
  if [ -x "$file" ]; then
    "./$file" &>> errors.txt
  fi
done
cd ..
