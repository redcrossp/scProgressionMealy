(
s.waitForBoot {
	// USER INPUT

	var initkKeyState = "c4"; // note name as scientific pitch notation (note then octave)
	var initProgression = 0;  // index of static progressions


	// diatonic roman numeral progressions
	~staticProgressions = [
		[1, 1, 4, 5],
		[1, 1, 2, 5],
		[1, 1, 6, 5],
		[1, 4, 2, 5]
	];
	~modulationProgressions = Dictionary[
		// the chromatic note to move to and the valid progressions to move there
		-5 -> [
			// down a perfect fourth
			[4, 4, 2, 5],
			[4, 4, 2, 7]
		],
		5 -> [
			// up a perfect fourth
			[3, 6, 2, 5],
			[3, 6, 2, 7]
		],
		7 -> [
			// up a perfect fifth
			[4, 4, 2, 5],
			[4, 4, 2, 7]
		]
	];

	// state machine
	~mealy = (
		// arbitrary starting progression and key center
		progression: ~staticProgressions.wrapAt(initProgression),
		keyCenter: initKeyState.asNote.value % 120,

		nextState: {
			// on modulate return 1, else return chord as MIDI
			var modulate = (10.rand < 3);
			if (modulate,
				{
					var newKey = ~modulationProgressions.keys.choose;
					~mealy.keyCenter = (~mealy.keyCenter + newKey) % 120;
					~mealy.progression = ~modulationProgressions.at(newKey).choose;
					"Modulated with new center: " ++ ~mealy.keyCenter;
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