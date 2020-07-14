package raindrops

import "strconv"
//import "fmt"

func Convert(i int) string {


// im not sure how do this correct way
	str := ""


	if i % 3 == 0 {
		str += "Pling"
	}
	if i % 5 == 0 {
		str += "Plang"
	}
	if i % 7 == 0 {
		str += "Plong"
	}
	if len(str) == 0 {
			//
   return strconv.Itoa(i) // Seems itoa best choise for speedup.
    // See: https://gist.github.com/evalphobia/caee1602969a640a4530

	}
  return str

/*
	for v := 0; v < i; v++ {

		x := ""
		y := ""
		z := ""

		if (i % 7) == 0 {
			x += "Plong"
		}
		if (i % 5) == 0 {
			y += "Plang"
		}
		if (i % 3) == 0 {
			z += "Pling"
		}
		fmt.Println("agaagsg", i)
		return z+y+x

	}*/


}
