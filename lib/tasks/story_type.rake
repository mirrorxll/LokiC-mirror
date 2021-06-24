# frozen_string_literal: true

namespace :story_type do
  desc 'filling in empty distributed_at TS for story types'
  task init_distributed_at: :environment do
    StoryType.where.not(developer: nil).each do |st_type|
      st_type.update(distributed_at: st_type.created_at)
    end
  end

  desc 'filling in empty last_status_changed_at TS for story types'
  task init_last_status_changed_at: :environment do
    StoryType.all.each do |st_type|
      st_type.update(last_status_changed_at: DateTime.now)
    end
  end

  desc 'mark story types as migrated'
  task init_last_status_changed_at: :environment do
    st_types = [2080, 2003, 2043, 2044, 2048, 2049, 2051, 2052, 2050, 2053, 2054, 2055, 2477, 2478, 2640, 2596, 2544, 2746, 2174, 2081, 2749, 2589, 2566, 2400, 2401, 2000, 2001, 2244, 2243, 2308, 2309, 2310, 2567, 2568, 2245, 2402, 2002, 2242, 2241, 2240, 2210, 2641, 2092, 2642, 2093, 2643, 2136, 2644, 2137, 2645, 2647, 2208, 2406, 2648, 27, 2719, 2385, 2284, 2342, 2343, 2344, 2345, 2346, 2341, 2246, 2247, 2248, 2249, 2273, 2272, 26, 2076, 46, 22, 23, 13, 2288, 47, 2311, 2312, 2313, 2314, 2315, 2653, 2654, 2103, 2655, 2660, 2664, 2661, 2662, 2663, 2099, 2289, 2100, 2665, 2666, 2667, 2359, 2045, 2207, 2669, 2668, 2046, 2290, 2671, 2672, 2673, 2674, 2675, 2153, 2676, 2677, 2678, 2680, 2681, 2682, 2683, 2684, 14, 2685, 2679, 2360, 2007, 2205, 45, 2074, 2361, 2224, 2075, 2204, 2225, 2138, 2753, 2754, 2106, 2026, 2369, 2362, 2022, 2698, 2301, 2298, 2699, 2700, 2299, 2701, 2704, 2162, 2709, 2710, 2300, 2706, 2707, 2711, 2708, 2705, 2636, 2302, 2303, 2305, 2687, 2688, 2307, 2689, 2304, 2690, 2594, 2306, 2316, 2691, 2692, 2379, 2713, 2714, 2715, 2716, 2717, 2718, 2637, 2712, 2638, 2658, 2656, 2452, 2670, 2490, 2202, 2201, 2659, 2657, 2498, 2163, 2319, 2370, 2693, 2694, 2702, 2703, 2382, 2695, 2696, 2296, 2697, 2320, 2297, 2491, 2752, 2487, 2324, 2325, 2145, 2146, 2147, 2148, 2197, 2198, 2199, 2200, 2476, 2488, 2033, 2409, 2108, 2177, 2546, 2410, 2882, 2441, 2883, 2431, 2884, 2109, 2547, 2552, 2125, 2597, 2180, 2807, 2808, 2562, 2806, 2804, 2885, 2411, 2077, 2181, 2117, 2118, 2844, 2387, 2842, 2482, 2226, 2119, 2805, 2485, 2486, 2489, 2839, 2841, 2227, 2598, 2809, 2810, 2840, 2388, 2389, 2120, 2121, 2538, 2559, 2843, 2777, 2513, 2107, 2110, 2111, 2112, 2113, 2751, 2115, 2116, 2778, 2783, 2476, 2033, 2784, 2196, 2779, 2785, 2467, 2780, 2468, 2195, 2781, 2469, 2786, 2470, 2094, 2412, 2413, 2095, 2183, 2184, 2185, 2186, 2187, 2188, 2190, 2024, 2553, 2156, 2157, 2886, 2887, 2390, 2391, 2414, 2415, 2158, 2159, 2416, 2417, 2160, 2161, 2096, 2097, 2460, 2591, 2592, 2593, 2854, 2855, 2856, 2545, 2782, 2787, 2788, 2722, 2442, 2443, 2444, 2445, 2725, 2407, 2646, 2723, 2726, 2727, 2033, 2033, 2033, 2033, 2033, 2033, 2033, 2033, 2563, 2564, 2649, 2650, 2141, 2142, 2143, 2144, 2193, 2194, 2554, 2569, 2014, 2570, 2879, 2556, 2571, 2880, 2881, 2555, 2025, 2557, 2558, 2572, 2573, 2574, 2461, 2813, 2814, 2811, 2812, 2815, 2816, 2817, 2818, 2819, 2730, 2731, 2732, 2733, 2734, 2735, 2736, 2737, 2857, 2858, 2859, 2860, 2861, 2862, 2863, 2864, 2865, 2866, 2867, 2868, 2869, 2651, 2652, 2611, 2612, 2613, 2614, 2738, 2424, 2739, 2615, 2616, 2617, 2295, 2519, 2164, 2191, 2520, 2392, 2521, 2522, 2393, 2539, 2394, 2192, 2540, 2541, 2165, 2166, 2542, 2167, 2425, 2849, 2789, 2790, 2168, 2169, 2850, 2851, 2852, 2853, 2791, 2792, 2170, 2171, 2223, 2172, 2173, 2543, 2793, 2794, 2033, 2033, 2033, 2033, 2033, 2033, 2033, 2033, 2033, 2033, 2033, 2721, 2033, 2845, 2846, 2847, 2848, 2773, 2021, 2774, 2775, 2776, 2056, 2795, 2338, 2339, 2377, 2340, 2378, 2456, 2454, 2457, 2458, 2459, 2796, 2797, 2824, 2825, 2826, 2827, 2828, 2479, 2455, 2480, 2481, 16, 17, 2426, 2427, 2428, 2429, 2835, 2831, 2127, 2129, 2277, 2763, 2128, 2383, 2384, 2018, 2019, 2020, 2836, 2834, 2720, 29, 2430, 2761, 2761, 2761, 2761, 2763, 2450, 2451, 2278, 2279, 2321, 2322, 2280, 2756, 2756, 2756, 2756, 2757, 2720, 1, 3, 2832, 2833, 2837, 2838, 2, 2561, 2720, 2060, 2029, 2030, 2720, 24, 2285, 43, 25, 2004, 2005, 2492, 2493, 2494, 2495, 2496, 2497, 2104, 2105, 2101, 2102, 28, 37, 2449, 2432, 2448, 2447, 2433, 2434, 2720, 2720, 2720, 2435, 2436, 2437, 2438, 2439, 2440, 2292, 2293, 2720, 2720, 2798, 2799, 2800, 8, 2801, 4, 5, 6, 7, 9, 10, 2720, 2720, 2334, 2334, 2334, 2768, 2335, 2766, 2533, 2534, 2535, 11, 2532, 2820, 2821, 2822, 2823, 2829, 2830, 2720, 2720, 2720, 2182, 2126, 2189, 2870, 2871, 2873, 2871, 2871, 2874, 2875, 12, 2021, 2018, 2019, 2020, 2876, 2529, 2767, 2635, 2633, 2363, 18, 2364, 2365, 2366, 2367, 2632, 2634, 2631, 2323, 2760, 2755, 2720, 2720, 2720, 2720, 2720, 2012, 21, 32, 2630, 30, 31, 33, 34, 38, 35, 40, 36, 2090, 2368, 39, 41, 2720, 2720, 2720, 2720, 2016, 44, 2017, 2028, 2031, 2032, 2059, 2042, 2070, 2091, 2175, 2176, 2720, 2720, 2720, 2720, 2720, 2720, 2034, 2035, 2036, 2037, 2038, 2039, 2040, 2041, 2063, 2720, 2720, 2720, 2720, 2720, 2720, 2720, 2720, 2720, 2720, 2720, 2720, 2720, 2720, 2720, 2720, 2720, 2720, 2720, 2720]
    StoryType.where(id: st_types).each { |stp| stp.update(migrated: true) }
  end
end
