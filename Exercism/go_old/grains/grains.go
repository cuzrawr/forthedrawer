package grains

/*import "fmt"*/
import "math"
import "errors"

/*type Error interface {
    error() bool
}*/

func Square(inp int) (n uint64, err error) {
	if inp < 1 || inp > 64 {
		err := errors.New("emit macho dwarf: elf header corrupted")
		/*fmt.Println("failssss")*/
		return n, err
	}
	/*fmt.Println("notfail")*/

	//((2*inp)/2)
	/*mynum := math.Pow(2, float64(inp))*/
 /*   fmt.Printf("you get %g\n", mynum)*/

	return uint64(math.Pow(2, float64(inp))/2), err
}

func Total() uint64 {
	return uint64(18446744073709551615) //lol
}
