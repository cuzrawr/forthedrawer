package reverse

func String(s string) string {

	str := ""

	for i := len([]rune(s)) - 1; i >= 0; i-- {
		str += string([]rune(s)[i])
	}
	return str
}
