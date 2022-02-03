package seedDataProcessor;

import java.lang.reflect.*;
import java.util.HashMap;
import java.util.List;

/**
 * This class represents all the data
 * read from a single line in the 
 * data files.
 * @author Nicholas Sixbury
 * @see seedLineFlagProps
 * @see seed
 */
public class SeedLine {
	/**
	 * The default value for flag tolerance across all seedLines.
	 * @see #getFlagTolerance()
	 * @see #setFlagTolerance(double)
	 */
	public static final double defaultFlagTolerance = 0.01;
	/**
	 * The default value for the number which indicates a
	 * particular SeedLine is a flag for a new row of seeds
	 * on the grid, based off of area.
	 * @see #getFlagTolerance()
	 * @see #setFlagTolerance(double)
	 * @see #area
	 */
	public static final double defaultNewRowFlagValue = 121;
	/**
	 * The default value for the number which indicates a
	 * particular SeedLine is a flag for the start to a new
	 * seed in the data, based off of area.
	 * @see #getFlagTolerance()
	 * @see #setFlagTolerance(double)
	 * @see area
	 */
	public static final double defaultSeedStartFlagValue = 81.7;
	/**
	 * The default value for the number which indicates a 
	 * particular SeedLine is a flag for the end of a seed's
	 * data, based off of area.
	 * @see #getFlagTolerance()
	 * @see #setFlagTolerance(double)
	 * @see #area
	 */
	public static final double defaultSeedEndFlagValue = 95.3;
	
	/**
	 * The seed object which currently contains this object.
	 * When unset, it is equal to Seed.blankSeed.
	 */
	public Seed currentSeedOwner = Seed.blankSeed();
	
	//public cell currentCellOwner = cell.blankCell;
	/**
	 * The tolerance for flag values. If the difference between
	 * a flag value and a the property we're comparing it against
	 * is less than this, then we should count that value as that
	 * flag.
	 * @see #defaultFlagTolerance
	 * @see #getFlagTolerance()
	 * @see #setFlagTolerance(double)
	 */
	protected static double flagTolerance = defaultFlagTolerance;
	/**
	 * @return returns the tolerance value 
	 * for flags. If a value is off by within
	 * the tolerance value, then it should be
	 * considered as the same as that flag.
	 * @see #setFlagTolerance(double)
	 * @see #defaultFlagTolerance
	 */
	public static double getFlagTolerance() {
		return flagTolerance;
	}//end getFlagTolerance()
	/**
	 * @param value The value to assign as
	 * the tolerance for flags. If a flag
	 * value is off by within the tolerance,
	 * then it should be considered as the
	 * same as that flag.
	 * @see #getFlagTolerance()
	 * @see #defaultFlagTolerance
	 */
	public static void setFlagTolerance(double value) {
		if(value <= 0) flagTolerance = 0;
		else flagTolerance = value;
	}//end setFlagTolerance(value)
	
	/**
	 * The current value indicating whether an something is a flag
	 * for a new row of seeds.
	 * @see #area
	 * @see #defaultNewRowFlagValue
	 * @see #getFlagTolerance()
	 * @see #setFlagTolerance(double)
	 * @see #isNewRowFlag()
	 */
	public static double newRowFlagValue = defaultNewRowFlagValue;
	/**
	 * Checks the area property of this object against the
	 * newRowFlagValue of this object in order to tell you
	 * whether this SeedLine is a flag for a new row of seeds
	 * in the grid. Takes flag tolerance into account.
	 * @return Whether or not the current
	 * SeedLine object is a flag for a new row.
	 * @throws NullPointerException Thrown
	 * when area field of this object is null.
	 * @see #area
	 * @see #newRowFlagValue
	 * @see #getFlagTolerance()
	 * @see #setFlagTolerance(double)
	 */
	public boolean isNewRowFlag() {
		if(area == null)
			throw new NullPointerException("The area field of this object is null.");
		if(area >= newRowFlagValue - flagTolerance
			&& area <= newRowFlagValue + flagTolerance) {
			return true;
		}//end if area within tolerance
		else return false;
	}//end isNewRowFlag()
	
	/**
	 * The value which is checked against the area of a SeedLine in
	 * order to find out if that row is a flag for the beginning of
	 * cell information.
	 * @see #area
	 * @see #defaultSeedStartFlagValue
	 * @see #getFlagTolerance()
	 * @see #setFlagTolerance(double)
	 * @see #isSeedStartFlag()
	 */
	public static double seedStartFlagValue = defaultSeedStartFlagValue;
	/**
	 * Checks the area property of this object against the
	 * seedStartFlagValue of this object in order to tell you
	 * whether this SeedLine is a flag for beginning data for a new
	 * seed. Takes flag tolerance into account.
	 * @return Whether or not the current SeedLine object is a
	 * flag for starting a new seed.
	 * @throws NullPointerException thrown when area field of
	 * this object is null.
	 * @see #area
	 * @see #seedStartFlagValue
	 * @see #getFlagTolerance()
	 * @see #setFlagTolerance(double)
	 */
	public boolean isSeedStartFlag() {
		if(area == null)
			throw new NullPointerException("The area field of this object is null.");
		if(area >= seedStartFlagValue - flagTolerance &&
			area <= seedStartFlagValue + flagTolerance) {
			return true;
		}//end if area within tolerance
		else return false;
	}//end isSeedStartFlag()
	
	/**
	 * The value which is checked against the area of a row in order
	 * to find out if that row is a flag for the end of a cell.
	 * @see #area
	 * @see #defaultSeedEndFlagValue
	 * @see #getFlagTolerance()
	 * @see #setFlagTolerance(double)
	 * @see #isSeedEndFlag()
	 */
	public static double seedEndFlagValue = defaultSeedEndFlagValue;
	/**
	 * Checks the area property of this object against the
	 * seedEndFlagValue of this object in order to tell you
	 * whether this SeedLine is a flag for beginning data for a new
	 * seed. Takes flag tolerance into account.
	 * @return Whether or not the current SeedLine object is a
	 * flag for ending the data for a seed.
	 * @throws NullPointerException thrown when area field of
	 * this object is null.
	 * @see #area
	 * @see #seedEndFlagValue
	 * @see #getFlagTolerance()
	 * @see #setFlagTolerance(double)
	 */
	public boolean isSeedEndFlag() {
		if(area == null)
			throw new NullPointerException("The area field of this object is null.");
		if(area >= seedEndFlagValue - flagTolerance &&
			area <= seedEndFlagValue + flagTolerance) {
			return true;
		}//end if area within tolerance
		else return false;
	}//end isSeedEndFlag()
	
	/**
	 * Gives access to an instance of an inner class which
	 * just has information on the flag-related fields of the
	 * SeedLine class.
	 * @return A seedLineFlagProps instance with fields set
	 * to be equal to the current {@link #flagTolerance},
	 * {@link #newRowFlagValue}, {@link #seedStartFlagValue},
	 * and {@link #seedEndFlagValue} field values of SeedLine.
	 * @see seedLineFlagProps
	 */
	public static seedLineFlagProps getCurrentFlagProps() {
		return new SeedLine().new seedLineFlagProps();
	}//end getCurrentFlagProps()

	/**
	 * The line number of this particular SeedLine. Useful for
	 * ordering SeedLine objects in the order they originally
	 * came in. 
	 * The value of -1 is a special value for this field which
	 * indicates the SeedLine is unordered.
	 */
	public int lineNum = -1;
	
	/*
	 * The following variables use wrappers
	 * for their type. There is a reason for
	 * this. Because imageJ can have different
	 * outputs for measurement columns, and
	 * we don't want to be stuff in a
	 * particular format, we allow columns
	 * to be null. That way, if we happen to
	 * find a column that's null, and we
	 * don't need that column, we can just
	 * ignore it. On the other hand, if we
	 * do need it, then we can tell the user
	 * that, and then cancel whatever process
	 * we were going to do.
	 */
	public Double area;
	public Double x;
	public Double y;
	public Double perim;
	public Double major;
	public Double minor;
	public Double angle;
	public Double circ;
	public Double ar;
	public Double round;
	public Double solidity;
	
	/**
	 * This hashmap contains aliases for each of the
	 * data columns that exist for the row class. The keys
	 * are various respellings and alternate names for ceratin
	 * columns/fields, and the value for each of those is the
	 * field in this class that corresponds to that alias.
	 * This allows us to use reflection in order to quickly
	 * and easily find the field that a string refers to.
	 * 
	 * @see #getColumnAlias(String)
	 */
	protected static HashMap<String, Field> columnAliases =
			new HashMap<String, Field>();
	/**
	 * When given an alias of one of the fields representing a column
	 * of data, returns the field in this class that corresponds to
	 * that column alias. This can only be done if the alias and
	 * field have both already been recorded.
	 * 
	 * @param key One of potentially several names that maps
	 * to a particular field of this class.
	 * @return Returns field that key is alias for. Null will be
	 * returned if nothing is found.
	 * @see #columnAliases
	 * @see #putColumnAlias(String, String)
	 */
	public static Field getColumnAlias(String key) {
		return columnAliases.get(key);
	}//end getColumnAlias(key)
	/**
	 * When given both the name of one of the fields in this class
	 * and an alias for that field, will update an internal hashmap
	 * to remebmer that alias for that field, allowing alternate names
	 * for fields to be stored, remembered, and retrieved efficiently.
	 * 
	 * @param key The alias or alternate name for the field. This is
	 * case sensitive.
	 * @param value The name of the field you wish to record an alias
	 * for. This is case sensitive and will be used with reflection
	 * in order to retrieve a Field object.
	 * @return Returns the previous value associated with the key,
	 * or null if it's a new alias. If this isn't null, you probably
	 * have issues.
	 * @throws NoSuchFieldException this exception is thrown if
	 * the class SeedLine doesn't have a field with a name of value.
	 * @see #columnAliases
	 * @see #getColumnAlias(String)
	 */
	public static Field putColumnAlias(String key, String value)
			throws NoSuchFieldException {
		try {
			Field foundField = SeedLine.class.getField(value);
			return columnAliases.put(key, foundField);
		}//end trying to confirm field we add an alias for exists
		catch (NoSuchFieldException e) {
			e.printStackTrace();
			throw new NoSuchFieldException("The field " + value +
				" does not exist in class SeedLine, so alias " +
				key + " is invalid and cannot be added.");
		}//end catching noSuchFieldExceptions 
	}//end putColumnAlias(key, value)

	/**
	 * Initializes column aliases with the default
	 */
	public static void putDefaultColumnAlias(){
		// this is just hardcoded for now
		String[] aliases = {"Area","X","Y","Perim.","Major",
		"Minor","Angle","Circ.","AR","Round","Solidity"};
		String[] fieldNames = {"area","x","y","perim","major",
		"minor","angle","circ","ar","round","solidity"};
		for(int i = 0; i < aliases.length; i++){
			try {
				SeedLine.putColumnAlias(aliases[i], fieldNames[i]);
			} catch (NoSuchFieldException e) {}
		}//end adding each alias
	}//end putDefaultColumnAlias()
	
	/**
	 * The default/empty constructor. Sets all fields to their
	 * default values.
	 */
	public SeedLine() {
		// defaults already set in field declaration ¯\_(ツ)_/¯
	}//end no-arg constructor
	
	/**
	 * Copies all the information over from another SeedLine.
	 * Sets currentSeed to seed.blankSeed.
	 * @param other The SeedLine whose data will be copied to
	 * make this object.
	 */
	public SeedLine(SeedLine other) {
		for(Field field : this.getClass().getFields()) {
			try {
				field.set(this, field.get(other));
			}//end trying to field of this to value in other
			catch (IllegalArgumentException e) {}
			catch (IllegalAccessException e) {}
		}//end looping over each public field in this class
		this.currentSeedOwner = Seed.blankSeed();
	}//end 1-arg copy constructor
	
	/**
	 * Constructor to initialize variables. Allows you to input
	 * double fields. Used in previous implementation of class
	 * as defined as "Row" in "Row.cs" of previous C# application.
	 * @param lineNum The line number for this particular SeedLine.
	 * This is used for determining order of seedLines. 
	 * @param fields a list of the default fields in the
	 * default order. That is, area, x, y, perim, major, minor,
	 * angle, circ, ar, round, and solidity.
	 * @throws IllegalArgumentException This exception is thrown
	 * if the length of fields is not 11.
	 * @deprecated
	 */
	public SeedLine(int lineNum, double[] fields) {
		if(fields.length != 11) {
			throw new IllegalArgumentException("The length of argument "
					+ "fields must be exactly 11, but instead it was "
					+ fields.length + ".");
		}//end if fields is the wrong length
		this.lineNum = lineNum;
		this.area = fields[0];
		this.x = fields[1];
		this.y = fields[2];
		this.perim = fields[3];
		this.major = fields[4];
		this.minor = fields[5];
		this.angle = fields[6];
		this.circ = fields[7];
		this.ar = fields[8];
		this.round = fields[9];
		this.solidity = fields[10];
	}//end 2-arg ordered array constructor
	
	/**
	 * Instantiates the class with unordered column data by associating
	 * each data value with a column alias.
	 * 
	 * @param lineNum The line number of this SeedLine object.
	 * @param columnData A hashmap in which each keyValuePair is
	 * a column alias paired with the value that should be assigned
	 * to the field in this class that corresponds to the column.
	 * @see #getColumnAlias(String)
	 * @see #putColumnAlias(String, String)
	 */
	public SeedLine(int lineNum,
			HashMap<String, Double> columnData) {
		// set line number
		this.lineNum = lineNum;
		// set all the data column stuff
		for(String alias : columnData.keySet()) {
			Field aliassedField = getColumnAlias(alias);
			if(aliassedField != null) {
				try {
					aliassedField.setDouble(this, columnData.get(alias));					
				}//end trying to set aliased field
				catch(IllegalAccessException e) {
					e.printStackTrace();
				}//end catching illegal access exceptions
			}//end if we did actually find something
		}//end looping over aliases
	}//end 2-arg unordered list constructor
	
	/**
	 * Instantiates the class from the string components of raw data
	 * input.
	 * 
	 * @param columns A list of the column headers.
	 * @param data A parallel list of data points for each of the column
	 * headers. These should all be parsable to double types.
	 * @param lineNum The line number of this seedLine.
	 * @see #getColumnAlias(String)
	 * @see #putColumnAlias(String, String)
	 */
	public SeedLine(List<String> columns,
			List<String> data, int lineNum) {
		if(columns.size() != data.size()) {
			throw new IllegalArgumentException("The size of columns is "
				+ columns.size() + ", but the size of data is " +
				data.size() + ". They are supposed to be the same size.");
		}//end if parallel array lists aren't same size
		// actually start data entry
		this.lineNum = lineNum;
		for(int i = 0; i < columns.size(); i++) {
			Field column = getColumnAlias(columns.get(i));
			if(column != null) {
				try {
					Double dataValue = Double.valueOf(data.get(i));
					try {
						// finally set the field to the right value
						column.set(this, dataValue);						
					}//end trying to set double field
					catch (IllegalAccessException e) {
						e.printStackTrace();
					}//end catching illegal access exceptions
				}//end trying to convert into a double
				catch (NumberFormatException e) {
					e.printStackTrace();
				}//end catching number format exceptions
			}//end if column isn't null
		}//end looping over each element of column plus data
	}//end 3-arg column-based constructor
	
	/**
	 * Constructos to initialize variables. Allows you to input
	 * decimal fields. Used in previous implementation of class
	 * as defined as "Row" in "Row.cs" of previous C# application.
	 * @param lineNum sets the {@link #lineNum} for this object
	 * @param area sets the {@link #area} for this object
	 * @param x sets the {@link #x} for this object
	 * @param y sets the {@link #y} for this object
	 * @param perim sets the {@link #perim} for this object
	 * @param major sets the {@link #major} for this object
	 * @param minor sets the {@link #minor} for this object
	 * @param angle sets the {@link #angle} for this object
	 * @param circ sets the {@link #circ} for this object
	 * @param ar sets the {@link #ar} for this object
	 * @param round sets the {@link #round} for this object
	 * @param solidity sets the {@link #solidity} for this object
	 * @deprecated
	 */
	public SeedLine(int lineNum, double area, double x, double y,
			double perim, double major, double minor, double angle,
			double circ, double ar, double round, double solidity) {
		this.lineNum = lineNum;
		this.area = area;
		this.x = x;
		this.y = y;
		this.perim = perim;
		this.major = major;
		this.minor = minor;
		this.angle = angle;
		this.circ = circ;
		this.ar = ar;
		this.round = round;
		this.solidity = solidity;
	}//end 12-arg constructor
	
	/**
	 * Compares values of all fields registered in column
	 * aliases, and returns true if all found fields are equal.
	 * Method will also ignore any fields that cause illegal
	 * access exceptions.
	 * 
	 * @param other The SeedLine object to compare this one to.
	 * @return Returns true if all aliassed fields are equal,
	 * or false if at least one is different.
	 * @see #getColumnAlias(String)
	 * @see #putColumnAlias(String, String)
	 */
	public boolean equals(SeedLine other) {
		for(Field field : SeedLine.columnAliases.values()) {
			try {
				boolean equality = field.get(this) == field.get(other);
				if(equality == false) return false;
			}//end trying to compare equality
			catch (IllegalAccessException e) {
				e.printStackTrace();
			}//end catching illegal access exceptions
		}//end looping over each aliassed field
		return true;
	}//end equals(other)
	
	/**
	 * Returns a string representation of this object. Includes
	 * line number in addition to all the aliassed fields. There's
	 * no really any particular order to the aliassed fields rn,
	 * so watch out for that.
	 */
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder();
		sb.append(lineNum + "\n");
		for(Field field : SeedLine.columnAliases.values()) {
			try {
				sb.append(field.get(this) + "\t");
			}//end trying to append this field
			catch (IllegalAccessException e) {
				e.printStackTrace();
			}//end catching illegal access exceptions
		}//end looping over each aliassed field
		return sb.toString();
	}//end toString()
	
	/**
	 * Returns a string with all of the data from the fields
	 * specified in columnAliases. Can also optionally include
	 * the line number at the beginning.
	 * 
	 * @param columnAliases Array of column aliases from which
	 * to pull data from this object's fields. 
	 * @param includeLineNum Whether or not to include the line
	 * number at the beginning of the string
	 * @return Returns a string with all the seed data formatted
	 * in the order of the columns.
	 * @throws IllegalArgumentException Thrown if one of the
	 * column aliases given could not be found in the internal
	 * column alias dictionary.
	 * @see #getColumnAlias(String)
	 * @see #putColumnAlias(String, String)
	 */
	public String formatData(String[] columnAliases,
			boolean includeLineNum) {
		StringBuilder sb = new StringBuilder();
		if(includeLineNum) {
			sb.append(lineNum + "\t");
		}//end if we should include the line number
		for(String alias : columnAliases) {
			try {
				Field field = getColumnAlias(alias);
				if(field != null) {
					Object value = field.get(this);
					if(value != null) {
						sb.append(value + "\t");					
					}//end if the value isn't null
					else {
						sb.append("null\t");
					}//end if the value is null					
				}//end if field isn't null
				else {
					throw new IllegalArgumentException("The alias " +
				alias + " was not found. Fields must be aliased " +
				"using the putColumnAlias() method before they " +
				"can be found by this class's reflections.");
				}//end else we have an un-aliased field
			}//end trying to do reflection stuff
			catch (IllegalAccessException e) {
				e.printStackTrace();
			}//end catching illegal access exceptions
		}//end looping over each column alias
		
		return sb.toString();
	}//end formatData(includeLineNum)
	
	// keep stuff above this
	
	/**
	 * A simple class for holding the properties concerning flags
	 * for the lines of data comprising a seed.
	 * @author Nicholas.Sixbury
	 * @see SeedLine
	 * @see SeedLine#flagTolerance
	 * @see SeedLine#newRowFlagValue
	 * @see SeedLine#seedStartFlagValue
	 * @see SeedLine#seedEndFlagValue
	 */
	public class seedLineFlagProps{
		/**
		 * The tolerance that should be applied to each flag.
		 * @see SeedLine#flagTolerance
		 */
		public double flagTolerance;
		/**
		 * The value of area which indicates a SeedLine is a flag for
		 * a new row of cells in the grid.
		 * @see #flagTolerance
		 * @see SeedLine#newRowFlagValue
		 */
		public double newRowFlagValue;
		/**
		 * The value of area which indicates a SeedLine is a flag for
		 * the beginning of seed data for a particular seed.
		 * @see #flagTolerance
		 * @see SeedLine#seedStartFlagValue
		 */
		public double seedStartFlagValue;
		/**
		 * The value fo area which indicates a SeedLine is a flag for
		 * the end of seed data for a particular seed.
		 * @see #flagTolerance
		 * @see SeedLine#seedEndFlagValue
		 */
		public double seedEndFlagValue;
		
		/**
		 * Initializes properties of this class with the current
		 * values for SeedLine.
		 * @see SeedLine#flagTolerance
		 * @see SeedLine#newRowFlagValue
		 * @see SeedLine#seedStartFlagValue
		 * @see SeedLine#seedEndFlagValue
		 */
		public seedLineFlagProps() {
			this.flagTolerance = SeedLine.flagTolerance;
			this.newRowFlagValue = SeedLine.newRowFlagValue;
			this.seedStartFlagValue = SeedLine.seedStartFlagValue;
			this.seedEndFlagValue = SeedLine.seedEndFlagValue;
		}//end no-arg constructor
		
		/**
		 * The copy constructor for this class.
		 * @param other The seedLineFlagProps object you wish to copy.
		 */
		public seedLineFlagProps(seedLineFlagProps other) {
			for(Field field : this.getClass().getFields()) {
				try {
					field.set(this, field.get(other));
				}//end trying to field of this to value in other
				catch (IllegalArgumentException e) {
					e.printStackTrace();
				}//end catching IllegalArgumentExceptions
				catch (IllegalAccessException e) {
					e.printStackTrace();
				}//end catching IllegalAccessExceptions
			}//end looping over each public field in this class
		}//end 1-arg copy constructor
		
		/**
		 * A constructor for initializing this class with all
		 * of its fields specified.
		 * @param flagTolerance sets value of {@link #flagTolerance}
		 * @param newRowFlagValue sets value of {@link #newRowFlagValue}
		 * @param seedStartFlagValue sets value of 
		 * {@link #seedStartFlagValue}
		 * @param seedEndFlagValue sets value of 
		 * {@link #seedEndFlagValue}
		 */
		public seedLineFlagProps(
				double flagTolerance, double newRowFlagValue,
				double seedStartFlagValue, double seedEndFlagValue) {
			this.flagTolerance = flagTolerance;
			this.newRowFlagValue = newRowFlagValue;
			this.seedStartFlagValue = seedStartFlagValue;
			this.seedEndFlagValue = seedEndFlagValue;
		}//end 4-arg constructor for making a new class
	}//end inner class seedLineFlagProps
}//end SeedLine
