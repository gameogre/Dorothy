class CCMotionStreak: public CCNode
{
	tolua_property__common CCTexture2D* texture;
	tolua_property__common ccBlendFunc blendFunc;
	
	tolua_property__bool bool fastMode;
	tolua_property__bool bool startingPositionInitialized @ startPosInit;
	
	void tintWithColor(ccColor3B colors);
	void reset();
	
	static CCMotionStreak* create(float fade, float minSeg, float stroke, ccColor3B color, const char* path);
	static CCMotionStreak* create(float fade, float minSeg, float stroke, ccColor3B color, CCTexture2D* texture);
};
