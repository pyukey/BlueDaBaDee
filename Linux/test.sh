correct=0

meow() {
  correct=$(($correct+1))
}
woof() {
  correct=$(($correct*2))
}

woof
meow
echo $correct
