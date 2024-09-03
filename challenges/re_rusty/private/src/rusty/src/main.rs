fn check_flag(flag: String)
{
	let mem = flag.into_bytes();

	if mem[0] == 106 && 
	   mem[1] == 99 && 
	   mem[2] == 116 && 
	   mem[3] == 102 && 
	   mem[4] == 123 &&
	   mem[54] == 125 {	   	
	   	let correct:Vec<u16> = vec![325,324,315,283,251,251,288,316,337,322, 327, 315, 321, 300, 320, 281, 281, 278, 327, 349, 323, 309, 306, 312, 310, 304, 314, 330, 329, 323, 322, 318, 308, 250, 242, 217, 230, 210, 209, 214, 215, 211, 212, 169, 137, 99, 99, 191, 264, 330];
	   	let size:usize = mem.len();
	   	for i in 0..50 {
	   		let k:usize = (5 + i) % size;
	   		let l:usize = (6 + i) % size;
	   		let m:usize = (7 + i) % size;
	   		let s:u16 = u16::from(mem[k])+u16::from(mem[l]) + u16::from(mem[m]);
	   		if s != correct[i] {	   			
	   			println!("lol. Not even close.");
	   			return;
	   		}
	   	}
	   	println!("Are you sure??? Try somewhere else.");	   
	} else {
		println!("lol. Not even close.");
	}
}

fn main() {
    println!("Give me the flag:");

    let mut line = String::new();
    std::io::stdin().read_line(&mut line).unwrap();
    line = line.trim().to_string();
    
    if line.len() == 55 {
    	check_flag(line);
	} else {
		println!("lol. That's not even close.");
	}
}
