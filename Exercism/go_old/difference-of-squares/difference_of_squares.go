package diffsquares

/*import "fmt"
*/


func SquareOfSums(ii int) int {
	ii = (ii*(ii+1)/2) * (ii*(ii+1)/2)
	return ii
}

func SumOfSquares(ii int) int {
	n := 0
	for i := 1; i <= ii; i++ {
		n += i*i
	}
/*
	return (n * (n + 1) * (2*n + 1)) / 6
*/
	return n
}

func Difference(ii int) int {
	return  SquareOfSums(ii) - SumOfSquares(ii)
}
