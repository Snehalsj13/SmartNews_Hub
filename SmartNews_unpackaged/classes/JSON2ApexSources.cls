public class JSON2ApexSources {

	public String status;
	public List<Sources> sources;

	public class Sources {
		public String id;
		public String name;
		public String description;
		public String url;
		public String category;
		public String language;
		public String country;
	}

	
	public static JSON2ApexSources parse(String json) {
		return (JSON2ApexSources) System.JSON.deserialize(json, JSON2ApexSources.class);
	}
}