package space
//import "fmt"
//import "math"

type Planet = string // IDK why You not declare this, wtf guys how I can know this shit in 3 exercise?


func Age(seconds float64, planet string) float64 {
	/*fmt.Println("seconds: ", seconds)
	fmt.Println("Planet: ", planet) //debug*/

	m := make(map[string]float64)
	m["Earth"] 	 = 1.0
	m["Mercury"] = 0.2408467
	m["Venus"]   = 0.61519726
	m["Mars"]    = 1.8808158
	m["Jupiter"] = 11.862615
	m["Saturn"]  = 29.447498
	m["Uranus"]  = 84.016846
	m["Neptune"] = 164.79132

	return ( seconds / (31557600.0 * m[planet]) )
	//high math here
	//	time in given seconds / (year on earth in second * ratio)

}

