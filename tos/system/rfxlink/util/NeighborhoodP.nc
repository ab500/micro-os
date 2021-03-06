#include <Neighborhood.h>

module NeighborhoodP
{
	provides
	{
		interface Init;
		interface Neighborhood;
		interface NeighborhoodFlag[uint8_t bit];
	}
}

implementation
{

	bool are_equal(ieee154_addr_t *addr1, ieee154_addr_t *addr2)
	{
		if (addr1->ieee_mode == IEEE154_ADDR_SHORT) {
			return addr1->ieee_addr.saddr == addr2->ieee_addr.saddr;
		}
		else {
			return addr1->ieee_addr.laddr == addr2->ieee_addr.laddr;
		}
	}

	tasklet_norace ieee154_addr_t nodes[NEIGHBORHOOD_SIZE];
	tasklet_norace uint8_t ages[NEIGHBORHOOD_SIZE];
	tasklet_norace uint8_t flags[NEIGHBORHOOD_SIZE];
	tasklet_norace uint8_t time;
	tasklet_norace uint8_t last;

	command error_t Init.init()
	{
		uint8_t i;

		for(i = 0; i < NEIGHBORHOOD_SIZE; ++i) {
			nodes[i].ieee_mode = IEEE154_ADDR_SHORT;
			nodes[i].ieee_addr.saddr = TOS_BCAST_ADDR;
		}
	
		return SUCCESS;
	}

	inline tasklet_async command ieee154_addr_t Neighborhood.getNode(uint8_t idx)
	{
		return nodes[idx];
	}

	inline tasklet_async command uint8_t Neighborhood.getAge(uint8_t idx)
	{
		return time - ages[idx];
	}

	tasklet_async uint8_t command Neighborhood.getIndex(ieee154_addr_t node)
	{
		uint8_t i;

		if (are_equal(&nodes[last], &node))
			return last;

		for(i = 0; i < NEIGHBORHOOD_SIZE; ++i)
		{
			if (are_equal(&nodes[i], &node))
			{
				last = i;
				break;
			}
		}

		return i;
	}

	tasklet_async uint8_t command Neighborhood.insertNode(ieee154_addr_t node)
	{
		uint8_t i;
		uint8_t maxAge;

		if (are_equal(&nodes[last], &node))
		{
			if( ages[last] == time )
				return last;

			ages[last] = ++time;
			maxAge = 0x80;
		}
		else
		{
			uint8_t oldest = 0;
			maxAge = 0;

			for(i = 0; i < NEIGHBORHOOD_SIZE; ++i)
			{
				uint8_t age;

				if (are_equal(&nodes[i], &node))
				{
					last = i;
					if( ages[i] == time )
						return i;

					ages[i] = ++time;
					maxAge = 0x80;
					break;
				}

				age = time - ages[i];
				if( age > maxAge )
				{
					maxAge = age;
					oldest = i;
				}
			}

			if( i == NEIGHBORHOOD_SIZE )
			{
				signal Neighborhood.evicted(oldest);

				last = oldest;
				nodes[oldest] = node;
				ages[oldest] = ++time;
				flags[oldest] = 0;
			}
		}

		if( (time & 0x7F) == 0x7F && maxAge >= 0x7F )
		{
			for(i = 0; i < NEIGHBORHOOD_SIZE; ++i)
			{
				if( (ages[i] | 0x7F) != time )
					ages[i] = time & 0x80;
			}
		}

		return last;
	}

	inline tasklet_async command bool NeighborhoodFlag.get[uint8_t bit](uint8_t idx)
	{
		return flags[idx] & (1 << bit);
	}

	inline tasklet_async command void NeighborhoodFlag.set[uint8_t bit](uint8_t idx)
	{
		flags[idx] |= (1 << bit);
	}

	inline tasklet_async command void NeighborhoodFlag.clear[uint8_t bit](uint8_t idx)
	{
		flags[idx] &= ~(1 << bit);
	}

	tasklet_async command void NeighborhoodFlag.clearAll[uint8_t bit]()
	{
		uint8_t i;

		bit = ~(1 << bit);

		for(i = 0; i < NEIGHBORHOOD_SIZE; ++i)
			flags[i] &= bit;
	}
}
