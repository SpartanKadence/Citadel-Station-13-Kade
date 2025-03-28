/**
 * checks distance from one thing to another but automatically resolving for turf / nesting
 *
 * todo: re-evaluate
 */
/proc/in_range_of(atom/A, atom/B, dist = 1)
	return game_range_to(A, B) <= dist

/**
 * gets real dist from A to B, including resolving for turf. if not the same Z, returns infinity.
 *
 * todo: this is silly, redo?
 */
/proc/game_range_to(atom/A, atom/B)
	A = get_turf(A)
	B = get_turf(B)
	return A.z == B.z? get_dist(A, B) : INFINITY

/**
 * real dist because byond dist doesn't go above 127 :/
 *
 * * Only accepts **turfs**. Undefined behavior if inputs are not turfs.
 */
/proc/get_turf_chebyshev_dist(turf/A, turf/B)
	return max(abs(A.x - B.x), abs(A.y - B.y))

/**
 * real euclidean dist
 *
 * * Only accepts **turfs**. Undefined behavior if inputs are not turfs.
 */
/proc/get_turf_euclidean_dist(turf/A, turf/B)
	return sqrt((A.x - B.x) ** 2 + (A.y - B.y) ** 2)

/**
 * real taxicab dist
 *
 * * Only accepts **turfs**. Undefined behavior if inputs are not turfs.
 */
/proc/get_turf_manhattan_dist(turf/A, turf/B)
	return abs(A.x - B.x) + abs(A.y - B.y)
