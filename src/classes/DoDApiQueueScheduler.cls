public class DoDApiQueueScheduler implements Schedulable {
  @testVisible private static String JOB_NAME = 'DoDApiQueueScheduler';
  public static void ScheduleMe (){
    DoDApiQueueScheduler m = new DoDApiQueueScheduler();
    // Seconds Minutes Hours Day_of_month Month Day_of_week Optional_year
    String sch;
    String jobID;
    sch = '0 0 * * * ?';
    jobID = system.schedule(JOB_NAME + ' 1/4', sch, m);
    sch = '0 15 * * * ?';
    jobID = system.schedule(JOB_NAME + ' 2/4', sch, m);
    sch = '0 30 * * * ?';
    jobID = system.schedule(JOB_NAME + ' 3/4', sch, m);
    sch = '0 45 * * * ?';
    jobID = system.schedule(JOB_NAME + ' 4/4', sch, m);
  }
  public void execute(SchedulableContext SC){
    Id queuedJobId;
    list<String> stoppedStatus = new list<String>{'Completed','Failed','Aborted'};
    ApexClass apiQueueClass = [select Id, Name from ApexClass where Name = 'DoDApiQueue'];
    list<AsyncApexJob> apexJob = [select Id, JobType, ApexClassId, Status from AsyncApexJob where Status not in :stoppedStatus and ApexClassId = :apiQueueClass.Id];
    if (apexJob.isEmpty()) {
      // need to queue the job
      // insert records and then queue
      queuedJobId = System.enqueueJob(new DoDApiQueue());
      
    } else {
      // job is already processing and will pick up additional records
      queuedJobId = apexJob[0].Id;
    }
    system.debug('queuedJobId: ' + queuedJobId);
  }

}