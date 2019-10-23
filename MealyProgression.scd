(
s.waitForBoot {



	~mealy = (
		progression: ~staticProgressions[0],
		keyCenter: 60,
		nextState: {
			var modulate = (10.rand < 3);
			if (modulate,
				{
					~mealy.keyCenter = ~mealy.keyCenter + 7;
					~mealy.progression = ~modulatingProgressions.choose;
				},
				{ ~mealy.progression = ~staticProgressions.choose; }
			);
		};
	);


	~major = Scale.major;

	~fromDegrees = { |array| array - 1; };
	~getChord = { |root|
		~major.degrees.wrapAt(~fromDegrees.([0,2,4] + root));
	};
	~getChordMidi = { |root, keyCenter| ~getChord.(root) + keyCenter; };

	~staticProgressions = [
		[1, 1, 4, 5],
		[1, 1, 2, 5],
		[1, 1, 6, 5],
		[1, 4, 2, 5]
	];
	// change key center first
	~modulatingProgressions = [
		[4, 4, 2, 5]
	];

	~mealy.nextState;
};
);