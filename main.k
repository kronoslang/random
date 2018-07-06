Import [kronoslang/sequence 0.1.0]
Import Algorithm

Package Random {
	Package Detail {
		LCG-Step(a c) {
			seed => 
				Coerce(Int32 
					Coerce(Int64 seed) * Coerce(Int64 a) 
					+ Coerce(Int64 c))
		}
	}

	Raw-Sequence(seed) {
		:Sequence:Cons(
			:Sequence:Infinite-Length
			seed (& 0x3fffffff) Detail:LCG-Step(1103515245i 12345i))
	}

	Sequence(seed range) {
		norm = range * Math:Pow(2 -30)
		Sequence:Map((* norm) Sequence(seed))
	}

	Bipolar-Sequence(seed magnitude) {
		norm  = magnitude * Math:Pow(2 -29)
		Sequence:Map(x => x * norm - magnitude 
					 Sequence(seed))
	}
}

Package Tiny-MT {
	; adapted from https://github.com/MersenneTwister-Lab
	; check:
	; tinymt32 0x8f7011ee 0xfc78ff1f 0x3793fdff seed = 1
	; 32-bit unsigned integers r, where 0 <= r < 2^32
	; 2545341989  981918433 3715302833 2387538352 3591001365 
	; 3820442102 2114400566 2196103051 2783359912 764534509 
	MEXP = 127i
	SH0 = 1i
	SH1 = 10i
	SH8 = 8i
	MASK = 0x7fffffff

	MAT1 = 0x8f7011ee
	MAT2 = 0xfc78ff1f
	TMAT = 0x3793fdff

	Infix^ = Xor

	Next-State(s0 s1 s2 s3) {
		x0 = (s0 & MASK) ^ s1 ^ s2
		x = BitShiftLeft(x0 SH0) ^ x0
		y = s3 ^ (LogicalShiftRight(s3 SH0) ^ x)
		(
			s1 
			s2 ^ (Neg(y & 1i) & MAT1)
			(x ^ BitShiftLeft(y SH1)) ^ (Neg(y & 1i) & MAT2)
			y
		)
	}

	Temper(s0 s1 s2 s3) {
		t0 = s3
		t1 = s0 + LogicalShiftRight(s2 SH8)
		(t0 ^ t1) ^ (Neg(t1 & 1i) & TMAT)
	}

	Rotate(i s0 s1 s2 s3) { (
			i + 1i
			s1 ^ (i + 1812433253i * (s0 ^ (LogicalShiftRight(s0 30i))))
			s2 s3 s0
		)
	}

	Init(seed) {
		(_ s3 s0 s1 s2) = Algorithm:Iterate(#7 Rotate 1i 
				Coerce(Int32 seed)
				MAT1
				MAT2
				TMAT)

		Algorithm:Iterate(#9 Next-State s0 s1 s2 s3)
	}


	Sequence(seed) {
		Sequence:Cons(
			Sequence:Infinite-Length
			Init(seed)
			Temper
			Next-State)
	}
}