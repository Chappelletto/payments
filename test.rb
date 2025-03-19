arr = [1, 2, 3, 4, 5]

arr.each_cons(2) {|i, t| pp i + t}