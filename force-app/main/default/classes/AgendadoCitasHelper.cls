public with sharing class AgendadoCitasHelper {
    @InvocableMethod(label='Recuperar Slots de Citas' description='Calcula los slots disponibles para el día, centro y especialidad seleccionados')
    public static List<List<String>> getSlotsFromAgendas(List<RequestData> requests) {
        
        List<List<String>> result = new List<List<String>>();

        RequestData req = requests[0];        

        Date fechaCita = req.fechaCita;
        String idCentro = req.idCentro;
        String idEspecialidad = req.idEspecialidad;
        String idEspecialista = req.idEspecialista;

        String query = 'SELECT Id, Hora_Inicio_Agenda__c, Hora_Final_Agenda__c ' +
               'FROM Agenda__c ' +
               'WHERE Dias_Disponibles__c INCLUDES (\'' + String.escapeSingleQuotes(req.diaDeLaSemana) + '\') ' +
               'AND Fecha_Inicio__c <= :fechaCita ' +
               'AND Fecha_Final__c >= :fechaCita ' +
               'AND Centro__c = :idCentro ' +
               'AND Especialidad__c = :idEspecialidad';

        List<Event> eventosExistentes = [SELECT Id, StartDateTime 
                                            FROM Event 
                                            WHERE (Especialidad__r.Especialista__c =: idEspecialista OR Especialidad__c =: idEspecialidad) AND ActivityDate = :fechaCita];
        Set<String> horasOcupadas = new Set<String>();
        for (Event ev : eventosExistentes) {
            if (ev.StartDateTime != null) {
                horasOcupadas.add(ev.StartDateTime.format('HH:mm'));
            }
        }
      
        List<Agenda__c> agendas = Database.query(query);
        for (Agenda__c agenda : agendas) {
            List<String> slots = new List<String>();
            Time startTime = agenda.Hora_Inicio_Agenda__c;
            Time endTime = agenda.Hora_Final_Agenda__c;
            while (startTime < endTime) {
                String slotStr = String.valueOf(startTime).substring(0, 5);
                // Solo añade el slot si no está ocupado
                if (!horasOcupadas.contains(slotStr)) {
                    slots.add(slotStr);
                }
                startTime = startTime.addMinutes(15);
            }
            result.add(slots);
        }
        return result;
    }

    public class RequestData {
        @InvocableVariable public String diaDeLaSemana;
        @InvocableVariable public Date fechaCita;
        @InvocableVariable public String idCentro;
        @InvocableVariable public String idEspecialidad;
        @InvocableVariable public String idEspecialista;
    }
}