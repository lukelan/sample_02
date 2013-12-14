//
//  LocationUtils.h
//  123Phim
//
//  Created by Le Ngoc Duy on 8/2/13.
//  Copyright (c) 2013 Phuong. Nguyen Minh. All rights reserved.
//

#ifndef ___23Phim__LocationUtils__
#define ___23Phim__LocationUtils__

#include <iostream>

class LocationUtils {
    
public:
    LocationUtils();
    /**
     * Lấy độ chênh lệch vĩ độ tương ứng với 50 mét
     */
    static double getApproximateLatitudeForMetres(double latitude,
                                    double longitude, float metres);
    /**
    * Lấy độ chênh lệch kinh độ tương ứng với 50 mét
    */
	static double getApproximateLongitudeForMetres(double latitude,
                                                   double longitude, float metres);
    /**
	 * Tính khoảng cách giữa 2 điểm dựa theo kinh độ và vĩ độ của 2 điểm đó
	 */
	static double computeDistance(double lat1, double lon1, double lat2,
                                         double lon2);
};
#endif /* defined(___23Phim__LocationUtils__) */
