

// wrapper for different enums useful in StageXX because processing can't embed it by itself...

public class StageState {

  public enum XP {
    // initializing
    INIT, 
    // starting xp
    START, 
    // starting new agent
    AGENT_START, 
    // new sentence
    SPEAK_START, 
    // speaking
    SPEAKING, 
    // sentence finished
    SPEAK_STOP, 
    // likert scale for sentence
    LIKERT_SENTENCE_START, 
    LIKERT_SENTENCE, 
    LIKERT_SENTENCE_STOP, 
    // likert scale for egent
    LIKERT_AGENT_START, 
    LIKERT_AGENT, 
    LIKERT_AGENT_STOP, 
    // agent finisheld
    AGENT_STOP, 
    // job done
    STOP
  }


  // diagram built with http://asciiflow.com/ 
  /*  
                                                                                                                                                  
                                                                                                                                                     
+-----------------------+       +-----------------------+                                     +-----------------------+                              
|                       |       |                       |          agent in list?             |                       |                              
|                       |       |                       |                                     |                       |                              
|      INIT          +------------->   START         +---------------------+--------------->  |      STOP             |                              
|                       |       |                       |                  |                  |                       |                              
|                       |       |          ^            |                  | yes              |                       |                              
+-----------------------+       +-----------------------+                  |                  +-----------------------+                              
                                           |                               |                                                                         
                                           |                   +-----------------------+                                                             
                                           |                   |           |           |                                                             
                                           |                   |           v           |  <----------------------------------------------------------
                                           |                   |      AGENT_START      |                                                            |
                                           | no                |                       |                                                            |
                                           |                   |                       |                                                            |
                                           |                   +----------+------------+                                                            |
                           +-------------> |                              |                                                                         |
                           |               |                              |                +-----------------------+                                |
                           |               |                      sentence|in list?        |                       |                                |
                           |               | likert for agent?            |                |                       |                                |
                           |               +------------------------------+----------------->     SPEAK_START      |                                |
                           |               |                        no          yes        |                       |                                |
                           |               |                                               |          +            |                                |
                           |               |                                               +-----------------------+                                |
                           |               | yes                                                      |                                             |
                           |               |                                               +-----------------------+                                |
                           |   +-----------------------+                                   |          |            |                                |
                           |   |           |           |                                   |          v            |                                |
                           |   |           v           |                                   |      SPEAKING         |                                |
                           |   | LIKERT_AGENT_START    |                                   |                       |                                |
                           |   |                       |                                   |          +            |                                |
                           |   |           +           |                                   +-----------------------+                                |
                           |   +-----------------------+                                              |                                             |
                           |               |                                               +-----------------------+                                |
                           |   +-----------------------+                                   |          |            |        likert for sentence?    |
                           |   |           |           |                                   |          v            |                     no         |
                           |   |           v           |                                   |      SPEARK_STOP    +-----------------+------------->  |
                           |   | LIKERT_AGENT_STOP     |                                   |                       |               |                |
                           |   |                       |                                   |                       |               |                |
                           |   |            +          |                                   +-----------------------+               | yes            |
                           |   +-----------------------+                                                                           |                |
                           |                |                                                                          +-----------------------+    |
                           |                |                                                                          |           |           |    |
                           +----------------+                                                                          |           v           |    |
                                                                                                                       | LIKERT_SENTENCE_START |    |
                                                                                                                       |                       |    |
                                                                                                                       |           +           |    |
                                                                                                                       +-----------------------+    |
                                                                                                                                   |                |
                                                                                                                       +-----------------------+    |
                                                                                                                       |           |           |    |
                                                                                                                       |           v           |    |
                                                                                                                       | LIKERT_SENTENCE_STOP +-----+
                                                                                                                       |                       |     
                                                                                                                       |                       |     
                                                                                                                       +-----------------------+     

   */
}
