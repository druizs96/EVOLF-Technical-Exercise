@isTest
public class AgendadoCitasHelperTest {
    @isTest
    static void testAgendasYSlots() {
        // Crear Centro
        Centro__c centro = new Centro__c(Name='Centro Test');
        insert centro;

        // Crear Especialista (Contact con RecordType "Especialista")
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Especialista' LIMIT 1];
        Contact especialista = new Contact(FirstName='Juan', LastName='Pérez', RecordTypeId=rt.Id);
        insert especialista;

        // Crear Especialidad
        Especialidad__c especialidad = new Especialidad__c(Name='Cardiología', Centro__c=centro.Id, Especialista__c=especialista.Id);
        insert especialidad;

        // Crear Agenda
        Agenda__c agenda = new Agenda__c(
            Centro__c = centro.Id,
            Especialidad__c = especialidad.Id,
            Dias_Disponibles__c = 'Lunes;Martes',
            Fecha_Inicio__c = Date.today(),
            Fecha_Final__c = Date.today().addDays(10),
            Hora_Inicio_Agenda__c = Time.newInstance(9, 0, 0, 0),
            Hora_Final_Agenda__c = Time.newInstance(10, 0, 0, 0)
        );
        insert agenda;

        // Probar trigger de duplicidad (debe fallar)
        Agenda__c agendaSolapada = new Agenda__c(
            Centro__c = centro.Id,
            Especialidad__c = especialidad.Id,
            Dias_Disponibles__c = 'Lunes',
            Fecha_Inicio__c = Date.today(),
            Fecha_Final__c = Date.today().addDays(5),
            Hora_Inicio_Agenda__c = Time.newInstance(9, 0, 0, 0),
            Hora_Final_Agenda__c = Time.newInstance(10, 0, 0, 0)
        );
        Test.startTest();
        try {
            insert agendaSolapada;
            System.assert(false, 'Debe lanzar error por solapamiento');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Ya existe una agenda'), 'Mensaje de error esperado');
        }

        // Probar AgendadoCitasHelper
        AgendadoCitasHelper.RequestData req = new AgendadoCitasHelper.RequestData();
        req.diaDeLaSemana = 'Lunes';
        req.fechaCita = Date.today();
        req.idCentro = centro.Id;
        req.idEspecialidad = especialidad.Id;

        List<AgendadoCitasHelper.RequestData> reqList = new List<AgendadoCitasHelper.RequestData>{req};
        
        List<List<String>> slots = AgendadoCitasHelper.getSlotsFromAgendas(reqList);
        Test.stopTest();
        System.assert(!slots.isEmpty(), 'Debe devolver al menos un slot disponible');
    }
}