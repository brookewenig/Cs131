import java.util.concurrent.atomic.AtomicIntegerArray;
class GetNSet implements State {
    private byte maxval;
    private AtomicIntegerArray value;
    
    GetNSet(byte[] v) { 
    	int[] temp = new int[v.length];
    	for (int i = 0; i < v.length; i++) {
    		temp[i] = v[i];
    	}
    	value = new AtomicIntegerArray(temp); 
		//Casting temp to atomic int array, same time put in value
    	maxval = 127; 
    	}

    GetNSet(byte[] v, byte m) { 
    	int[] temp = new int[v.length];
    	for (int i = 0; i < v.length; i++) {
    		temp[i] = v[i];
    	}
    	value = new AtomicIntegerArray(temp); 
    	maxval = m; 
    	}

    public int size() { return value.length(); }

    public byte[] current() { 
    	byte[] temp = new byte[value.length()];
    	for (int i = 0; i < value.length(); i++) {
    		temp[i] = (byte) value.get(i);
    	}
    	return temp;
    
    }

    public boolean swap(int i, int j) {
	if (value.get(i) <= 0 || value.get(j) >= maxval) {
	    return false;
	}
	value.set(i, value.get(i) - 1); 
	//This is NOT reliable b/c separation between the load and save
	value.set(j, value.get(j) + 1);
	return true;
    }
}
