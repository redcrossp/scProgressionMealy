(
s.waitForBoot {

	// diatonic roman numeral progressions
	~staticProgressions = [
		[1, 1, 4, 5],
		[1, 1, 2, 5],
		[1, 1, 6, 5],
		[1, 4, 2, 5]
	];
	~modulatingProgressions = [
		[4, 4, 2, 5]
	];

	// state machine
	~mealy = (
		// arbitrary starting progression and key center
		progression: ~staticProgressions[0],
		keyCenter: 60,

		nextState: {
			// on modulate return 1, else return chord as MIDI
			var modulate = (10.rand < 3);
			if (modulate,
				{
					~mealy.keyCenter = ~mealy.keyCenter + 7;
					~mealy.progression = ~modulatingProgressions.choose;
					1;
				},
				{
					~mealy.progression = ~staticProgressions.choose;
					~getMidiChordProgression.(~mealy.progression, ~mealy.keyCenter);
				}
			);
		};
	);


	~major = Scale.major;

	~fromDegrees = {
		// go from 0-based cs-ness to 1-based scale degress
		|array| array - 1;
	};
	~getChord = {
		// get relative chromatic scale degrees of chord
		|root|
		~major.degrees.wrapAt(~fromDegrees.([0,2,4] + root));
	};
	~getMidiChord = {
		// get midi notes of chord relative to keyCenter
		|root, keyCenter|
		~getChord.(root) + keyCenter;
	};
	~getMidiChordProgression = {
		// get midi notes of chord progression as nested array
		|roots, keyCenter|
		var chords = List[];
		roots.do{ |root|
			chords.add(~getMidiChord.(root, keyCenter));
		};
		chords;
	};

	~mealy.nextState;
};
);