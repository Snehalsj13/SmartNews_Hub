public class JSON2Apex {

	public String status;
	public Integer totalResults;
	public List<Articles> articles;

	public class Articles {
		public Source source;
		public String author;
		public String title;
		public String description;
		public String url;
		public String urlToImage;
		public String publishedAt;
		public String content;
	}

	public class Source_Z {
		public String id;
		public String name;
	}

	public class Source {
		public Object id;
		public String name;
	}

	
	public static JSON2Apex parse(String json) {
		return (JSON2Apex) System.JSON.deserialize(json, JSON2Apex.class);
	}
}