(
s.waitForBoot {
	// USER INPUT

	var initKeyState = "c4"; // note name as scientific pitch notation (note then octave)

	// Input for state machine transitions, integers only
	// -0 indicates staying in the same key
	// -Non-zero values indicate modulation, with the value indicating
	//  the interval to modulate to (must be in the progressions
	//  dictionary or the state machine will not modulate)
	var progressionList = [0, 5, 0, 7, 0, 0, -5];

	// dict of diatonic roman numeral chord progressions
	//   the dict key is the relative chromatic degree to move to before emitting progression
	//   consequently, the 0 key means the progression is in the same key as the previous output
	~progressions = Dictionary[
		// static chord progressions
		0 -> [
			[1, 1, 4, 5],
			[1, 1, 2, 5],
			[1, 1, 6, 5],
			[1, 4, 2, 5]
		],

		// modulating progressions
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
		progressions: Pseq(progressionList).asStream,
		keyCenter: initKeyState.asNote.value % 120,

		nextState: {
			var newKey = ~mealy.progressions.next;
			~mealy.keyCenter = (~mealy.keyCenter + newKey) % 120;
			~mealy.progression = ~progressions.at(newKey).choose;
			~getMidiChordProgression.(~mealy.progression, ~mealy.keyCenter);
			// ("Key center " ++ ~mealy.keyCenter ++ ", chords " ++ <OUTPUT HERE>).postln;
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

	progressionList.size.do({ ~mealy.nextState.postln; });
};
);