class oUnitDef: public CCObject
{
	enum
	{
		GroundSensorTag = 0,
		DetectSensorTag = 1,
		AttackSensorTag = 2
	};
	enum
	{
		BulletKey = 0,
		AttackKey = 1,
		HitKey = 2
	};
	
	tolua_property__bool bool static;
	tolua_property__common float scale;
	tolua_property__common float density;
	tolua_property__common float friction;
	tolua_property__common float restitution;
	tolua_property__common string model;
	tolua_property__common CCSize size;
	tolua_readonly tolua_property__common oBodyDef* bodyDef;

	int type;
	int reflexArc;
	float sensity;
	float move;
	float jump;
	float detectDistance;
	float maxHp;
	float attackBase;
	float attackDelay;
	float attackEffectDelay;
	CCSize attackRange;
	oVec2 attackPower;
	oAttackType attackType;
	oAttackTarget attackTarget;
	oTargetAllow targetAllow;
	unsigned short damageType;
	unsigned short defenceType;
	int bulletType;
	int attackEffect;
	int hitEffect;
	string name;
	string desc;
	string sndAttack;
	string sndDeath;

	tolua_outside void oUnitDef_setActions @ setActions(int actions[tolua_len]);
	tolua_outside void oUnitDef_setInstincts @ setInstincts(int instincts[tolua_len]);
	
	static bool usePreciseHit;
	static oUnitDef* create();
};
