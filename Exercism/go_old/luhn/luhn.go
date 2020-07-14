package luhn


/*import "fmt"*/
/*import "strings"
import "strconv"*/
import (
	"sort"
	"strings"

)
//reverse
func Reverse(input string) string {
	s := strings.Split(input, " ")
	sort.Sort(sort.Reverse(sort.StringSlice(s)))
	return strings.Join(s, " ")
}

func Valid(s string) bool {
		if len(s) < 2 {
			/*fmt.Println("flasestart")*/
			return false
		}
		/*if int(s) + int(s) == 0 {
			return false
		}*/

		//numberscheck
		stringq := strings.Replace(s, " ", "", -1)
		stringq = strings.Replace(stringq, "-", "0000000000000;asfs           fuckyou fkhj", -1)
		/*stringq = strings.Replace(stringq, "-", "", -1)*/
/*	fmt.Println("replaced str: ", stringq)*/

	if stringq == "0" {
		return false
	}
	//


	 xds :=	Reverse(stringq)

	 /*if _, err := strconv.Atoi(s); err != nil {

			 fmt.Println("flasenondigit", xds)
    return false

	}*/


	/* fmt.Println(xds)*/




/*	fmt.Println("s+s:::: ",s+s)
	if s + s == "0" {
  	return false
  	fmt.Println("falseeeeeeeeeeeeeeeee summ")
  	}*/
	/*stringq := strings.Replace(s, " ", "", -1)
	fmt.Println("replaced str: ", stringq)
	if _, err := strconv.Atoi(stringq); err != nil {
    return false
	}*/

  var sum = 0
  var nDigits = len(xds)
  var parity = nDigits % 2

  for i := 0; i < nDigits; i++ {
    var digit = int(xds[i] - 48)
    if i%2 == parity {
      digit *= 2
      if digit > 9 {
          digit -= 9
        }
    }
    sum += digit
  }
/*  fmt.Println("sum+sum:::: ",sum+sum)
  if string(sum + sum) == string(0) {
  	return false
  	fmt.Println("falseeeeeeeeeeeeeeeee summ")
  }*/

  return sum%10 == 0



/*
	stringq := strings.Replace(s, " ", "", -1)
	fmt.Println("replaced str: ", stringq)
	if _, err := strconv.Atoi(stringq); err != nil {
    return false
	}

	x := []byte(stringq)*/
	/*ii, _ := strconv.Atoi(string(x))

	 fmt.Println("conv: ", ii)*/

/*
		if len(x) % 2 == 0 {*/
	/*	stringq += string(0)
		x = []byte(stringq)*/
/*		stringq = strings.Replace(stringq, "", "0", 1)
		x = []byte(stringq)
		fmt.Println("non: ", string(x))
	}*/



/*	z := 0
	for i := len(x) -1 ; i >= 0 ; i--{

		if i % 2 == 1 {
			n, _ := strconv.Atoi(string(x[i]))
			n += n
				if n > 9 {
					n -= 9
				}


		z += n

		}
		if i % 2 == 0 {
			n, _ := strconv.Atoi(string(x[i]))
			z += n
		}

	}*/


/*
		fmt.Println("orign: ",z)*/
		/*k := strconv.Itoa(z)*/
		/*if cap(z) > 1 {

		}*/
/*


		if k[len(k)-1] == "0"|| z % 10 == 0 {
			return true
		} else {
			return false
		}*/
}
