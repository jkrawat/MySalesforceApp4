public class Trailympicscontroller {

     public List<PieWedgeData> getBarData() {
        List<PieWedgeData> data = new List<PieWedgeData>();
        data.add(new PieWedgeData('Analytics', 2));
        data.add(new PieWedgeData('AI', 2));
        data.add(new PieWedgeData('Heroku', 1));
        data.add(new PieWedgeData('Lightning', 7));
        data.add(new PieWedgeData('NA', 1));
        data.add(new PieWedgeData('Salesforce DX', 1));        
        return data;
    }

     public List<PieWedgeData> getPieData() {
        List<PieWedgeData> data = new List<PieWedgeData>();
        data.add(new PieWedgeData('Analytics', 6));
        data.add(new PieWedgeData('Artificial Intelligence', 9));
        data.add(new PieWedgeData('Heroku', 3));
        data.add(new PieWedgeData('Integration', 4));
        data.add(new PieWedgeData('Lightning', 17));
        data.add(new PieWedgeData('Moblile App', 6));
        data.add(new PieWedgeData('NA', 5));
        data.add(new PieWedgeData('Salesforce DX', 4));
        data.add(new PieWedgeData('Security', 6));
        
        return data;
    }

    // Wrapper class
    public class PieWedgeData {

        public String name { get; set; }
        public Integer data { get; set; }

        public PieWedgeData(String name, Integer data) {
            this.name = name;
            this.data = data;
        }
    }

}