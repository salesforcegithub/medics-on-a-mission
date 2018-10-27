/*
  Abstract for added get put for apex class objects
*/
public abstract class DoDCore {
  // transient - prevent the private variable from being added during JSON serialize
  Transient private Map<String, Object> self = new Map<String, Object>();
   // "Dynamic" getter
  public Object get(String key) {
      return this.self.get(key);
  }
  // "Dynamic" setter
  public void put(String key, Object value) {
      this.self.put(key, value);
  }
}