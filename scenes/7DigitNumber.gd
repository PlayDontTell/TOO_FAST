extends Sprite


var symbols = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]


func write_number(number):
	var string_number = str("%*.*f" % [8, 2, number])
	var caracter_to_draw: int
	for i in string_number.length():
		if string_number[i] in symbols:
			caracter_to_draw = int(string_number[i])
		elif string_number[i] == ".":
			caracter_to_draw = 11
		else:
			caracter_to_draw = 10
		get_node("Figure_" + str(i+ 1)).frame = caracter_to_draw
