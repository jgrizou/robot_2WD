#ifndef SimpleDeque_h
#define SimpleDeque_h

template<typename T, int rawSize>
class SimpleDeque
{
  public:
    SimpleDeque();
		
	void push(T element);
	void fill(T element);

	T sum();
	T mean();

	int index;
	T raw[rawSize];
};

template<typename T, int rawSize>
SimpleDeque<T,rawSize>::SimpleDeque() {
	index = 0;
}

template<typename T, int rawSize>
void SimpleDeque<T,rawSize>::push( T element ) {
	raw[index] = element;
	index = index + 1;                    
    if (index >= rawSize) {           
      index = 0;   
    }
}

template<typename T, int rawSize>
void SimpleDeque<T,rawSize>::fill( T element ) {
	for (int i = 0; i < rawSize; i++) 
	{
		raw[i] = element;
	}
}

template<typename T, int rawSize>
T SimpleDeque<T,rawSize>::sum() {
	T total = 0;
	for (int i = 0; i < rawSize; i++) 
	{
		total = total + raw[i];
	}
	return total;
}

template<typename T, int rawSize>
T SimpleDeque<T,rawSize>::mean() {
	return sum()/rawSize;
}

#endif
